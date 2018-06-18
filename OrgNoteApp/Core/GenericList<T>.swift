//
//  GenericTableController<T>.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 13.05.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import UIKit

/// A generic table view controller.
/// A table view can contain different cells in a section and
/// different kinds of sections. This property is acheived by
/// using a type erased CellDescriptor.
///
/// - note: see `CellDescriptor.any()` for more info
final class ListViewController<T: Hashable>: UITableViewController {

    private(set) var sectionDescriptors: [ListSectionDescriptor<T>]

    init(with models: [ListSectionDescriptor<T>], style: UITableViewStyle = .grouped) {
        self.sectionDescriptors = models
        super.init(style: style)
//        self.tableView.autoresizesSubviews = true
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50
    }

    func update(with newModels: [ListSectionDescriptor<T>]) {
        if newModels.count == self.sectionDescriptors.count && newModels.count == 1 {
            singleSectionDiffUpdate(with: newModels.first!)
        } else {
            multiSectionDiffUpdate(with: newModels)
        }
    }

    private func multiSectionDiffUpdate(with newModels: [ListSectionDescriptor<T>]) {
        let currentModels = self.sectionDescriptors
        self.sectionDescriptors = newModels
        let diffed = exceptUnchanged(diff(currentModels, newModels))
        tableView.beginUpdates()
        diffed.forEach { diffRes in
            switch diffRes {
            case let .deleted(item: _, fromIndex: idx):
                self.tableView.deleteSections(IndexSet(integer: idx), with: .automatic)
            case let .inserted(item: _, atIndex: idx):
                self.tableView.insertSections(IndexSet(integer: idx), with: .automatic)
            case let .moved(item: _, fromIndex: idx1, toIndex: idx2):
                self.tableView.moveSection(idx1, toSection: idx2)
            default:
                break
            }
        }
        tableView.endUpdates()
    }

    private func singleSectionDiffUpdate(with newModel: ListSectionDescriptor<T>) {
        let currentModels = self.sectionDescriptors
        self.sectionDescriptors = [newModel]

        assert(self.sectionDescriptors.count == 1, "Single section diff is only applicable for 1 section")
        tableView.beginUpdates()
        let diffResult = diffSection(currentModels.first!, newModel)
        diffResult.forEach { res in
            switch res {
            case let .deleted(item: _, fromIndex: idx):
                self.tableView.deleteRows(at: [IndexPath(row: idx, section: 0)], with: .automatic)
            case let .inserted(item: _, atIndex: idx):
                self.tableView.insertRows(at: [IndexPath(item: idx, section: 0)], with: .automatic)
            case let .moved(item: _, fromIndex: idx1, toIndex: idx2):
                self.tableView.moveRow(at: IndexPath(row: idx1, section: 0), to: IndexPath(row: idx2, section: 0))
            default:
                break
            }
        }
        tableView.endUpdates()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("initCoder: not implemented")
    }

    private func model(at indexPath: IndexPath) -> ListCellDescriptor<T, UITableViewCell> {
        return self.sectionDescriptors[indexPath.section].items[indexPath.row]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionDescriptors.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionDescriptors[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentItem = model(at: indexPath)
        if let cell = tableView.dequeueReusableCell(withIdentifier: currentItem.reuseIdentifier) {
            currentItem.configure(cell)
            return cell
        } else {
            tableView.register(currentItem.cellClass, forCellReuseIdentifier: currentItem.reuseIdentifier)
            let cell = tableView.dequeueReusableCell(withIdentifier: currentItem.reuseIdentifier, for: indexPath)
            currentItem.configure(cell)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentItem = model(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        currentItem.onSelect?()
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sectionDescriptors[section].footerText
    }

}
