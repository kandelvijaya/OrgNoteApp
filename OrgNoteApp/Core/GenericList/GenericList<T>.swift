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
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50
    }

    func update(with newModels: [ListSectionDescriptor<T>]) {
        let currentModels = self.sectionDescriptors
        self.sectionDescriptors = newModels
        let diffResult = orderedOperation(from: diff(currentModels, newModels))

        
        /// first diff on deeper level
        let internalEdits = internalDiff(from: diffResult)
        internalEdits.forEach { performRowChanges($0.operations, at: $0.offset) }

        /// extenal diff
        performSectionChanges(diffResult)
    }

    func performSectionChanges<T>(_ diffSet: [Operation<ListSectionDescriptor<T>>.Simple]) {
        tableView.beginUpdates()
        diffSet.forEach { item in
            switch item {
            case let .deletion(_, fromIndex):
                self.tableView.deleteSections(IndexSet(integer: fromIndex), with: .automatic)
            case let .addition(_, atIndex):
                self.tableView.insertSections(IndexSet(integer: atIndex), with: .automatic)
            case .update:
                // This should be handled prior to the section update.
                break
            }
        }

        tableView.endUpdates()
    }

    func performRowChanges<T>(_ diffSet: [Operation<ListCellDescriptor<T, UITableViewCell>>.Simple], at sectionIndex: Int) {
        tableView.beginUpdates()
        diffSet.forEach { cellDiffRes in
            switch cellDiffRes {
            case let .deletion(_, atIndex):
                self.tableView.deleteRows(at: [IndexPath(row: atIndex, section: sectionIndex)], with: .automatic)
            case let .addition(_, idx):
                self.tableView.insertRows(at: [IndexPath(item: idx, section: sectionIndex)], with: .automatic)
            default:
                // UITableView only supports section and cell level diffing.
                // Any lowerlevel diff will/should be applied on cell level.
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
