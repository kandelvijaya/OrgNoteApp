//
//  GenericTableController<T>.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 13.05.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import UIKit
import FastDiff

struct ListActionHandler {

    var onExit: ClosedBlock?
    var onRefreshContents: ClosedBlock?

    fileprivate static func empty() -> ListActionHandler {
        return ListActionHandler(onExit: nil, onRefreshContents: nil)
    }

}

/// A generic table view controller.
/// A table view can contain different cells in a section and
/// different kinds of sections. This property is acheived by
/// using a type erased CellDescriptor.
///
/// - note: see `CellDescriptor.any()` for more info
class ListViewController<T: Hashable>: UITableViewController {

    private(set) var sectionDescriptors: [ListSectionDescriptor<T>]
    private let handlers: ListActionHandler

    init(with models: [ListSectionDescriptor<T>], style: UITableViewStyle = .grouped, actionsHandler: ListActionHandler = .empty()) {
        self.sectionDescriptors = models
        self.handlers = actionsHandler
        super.init(style: style)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50
    }

    private func packingConsequetiveDeleteAddWithUpdate<T>(from diffResult:  [DiffOperation<T>.Simple]) -> [DiffOperation<T>.Simple] {
        if diffResult.isEmpty { return [] }

        var currentSeekIndex = 0 // This is the index that is not processed.

        var accumulator: [DiffOperation<T>.Simple] = []
        while currentSeekIndex < diffResult.count {
            let thisItem = diffResult[currentSeekIndex]
            let nextIndex = currentSeekIndex.advanced(by: 1)

            if nextIndex < diffResult.count {
                let nextItem = diffResult[nextIndex]
                switch (thisItem, nextItem) {
                    case let (.delete(di, dIndex), .add(ai, aIndex)) where dIndex == aIndex:
                        let update = DiffOperation<T>.Simple.update(di, ai, dIndex)
                        accumulator.append(update)
                    default:
                        accumulator.append(thisItem)
                        accumulator.append(nextItem)
                }
                currentSeekIndex = nextIndex.advanced(by: 1)
            } else {
                // This is the last item
                accumulator.append(thisItem)
                // This breaks the iteration
                currentSeekIndex = nextIndex
            }
        }
        return accumulator
    }

    func update(with newModels: [ListSectionDescriptor<T>]) {
        let currentModels = self.sectionDescriptors
        let diffResultTemp = orderedOperation(from: diff(currentModels, newModels))

        /// We need to pack Section with delete(aI) and add(aI) as update(old, new, aI)
        /// This is so that the we can maintain the previous state in the list +- the change
        let diffResult = packingConsequetiveDeleteAddWithUpdate(from: diffResultTemp)

        tableView.performBatchUpdates({
            self.sectionDescriptors = newModels

            /// first diff on deeper level
            let internalEdits = internalDiff(from: diffResult)
            internalEdits.forEach { performRowChanges($0.operations, at: $0.offset) }

            /// extenal diff
            performSectionChanges(diffResult)
        }) { (completed) in
            // Fall back if the batch update fails
            if completed == false {
                self.tableView.reloadData()
            }
        }
    }

    func performSectionChanges<T>(_ diffSet: [DiffOperation<ListSectionDescriptor<T>>.Simple]) {
        diffSet.forEach { item in
            switch item {
            case let .delete(_, fromIndex):
                self.tableView.deleteSections(IndexSet(integer: fromIndex), with: .fade)
            case let .add(_, atIndex):
                self.tableView.insertSections(IndexSet(integer: atIndex), with: .fade)
            case .update:
                // This should be handled prior to the section update.
                break
            }
        }
    }

    func performRowChanges<T>(_ diffSet: [DiffOperation<ListCellDescriptor<T, UITableViewCell>>.Simple], at sectionIndex: Int) {
        diffSet.forEach { cellDiffRes in
            switch cellDiffRes {
            case let .delete(_, atIndex):
                self.tableView.deleteRows(at: [IndexPath(row: atIndex, section: sectionIndex)], with: .fade)
            case let .add(_, idx):
                self.tableView.insertRows(at: [IndexPath(item: idx, section: sectionIndex)], with: .fade)
            default:
                // UITableView only supports section and cell level diffing.
                // Any lowerlevel diff will/should be applied on cell level.
                break
            }
        }
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("initCoder: not implemented")
    }

    func model(at indexPath: IndexPath) -> ListCellDescriptor<T, UITableViewCell> {
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        handlers.onExit?()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if handlers.onRefreshContents != nil {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.tintColor = .purple
            self.refreshControl?.addTarget(self, action: #selector(refreshContents), for: UIControlEvents.valueChanged)
        }
    }

    @objc private func refreshContents(_ sender: Any) {
        self.handlers.onRefreshContents?()
        self.refreshControl?.endRefreshing()
    }

}
