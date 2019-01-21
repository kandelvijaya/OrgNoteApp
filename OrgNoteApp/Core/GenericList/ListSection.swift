//
//  ListSection.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 13.05.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import UIKit
import FastDiff

/// Describes a list section.
struct ListSectionDescriptor<T: Hashable>: Hashable {

    //TODO: Why does [ListCellDescriptor<T, UITableViewCell>] not have default hashValue
    var hashValue: Int {
        guard let first = items.first else {
            return 0
        }
        var acc = first.hashValue
        let others = Array(items.dropFirst())
        for thisOne in others {
            let accCopy = acc
            acc = accCopy ^ thisOne.hashValue
        }
        let hash = footerText.map { acc ^ $0.hashValue } ?? acc
        return hash
    }

    let items: [ListCellDescriptor<T, UITableViewCell>]
    let footerText: String? = nil
    let identifier: Int

}

extension ListSectionDescriptor {

    init(with items: [ListCellDescriptor<T, UITableViewCell>]) {
        self.items = items
        self.identifier = 0 // Might be required later on
    }

}


/// Describes a cell item and its interaction
struct ListCellDescriptor<Model: Hashable, CellType: UITableViewCell>: Hashable {

    var hashValue: Int {
        return model.hashValue ^ reuseIdentifier.hashValue ^ cellClass.hash()
    }

    static func == (lhs: ListCellDescriptor<Model, CellType>, rhs: ListCellDescriptor<Model, CellType>) -> Bool {
        return lhs.model == rhs.model &&
            lhs.cellClass == rhs.cellClass &&
            lhs.reuseIdentifier == rhs.reuseIdentifier
    }


    let model: Model
    let reuseIdentifier: String
    let cellClass: CellType.Type
    let configure: (CellType) -> Void
    var onSelect: (() -> Void)? = nil
    var onPerfromAction: ((OutlineAction) -> Void)? = nil

    init(_ model: Model, identifier: String, cellClass: CellType.Type, configure: @escaping ((CellType) -> Void) = {_ in }) {
        self.model = model
        reuseIdentifier = identifier
        self.cellClass = cellClass
        self.configure = configure
    }

}


extension ListCellDescriptor {


    /// produces type erased ListCellDescriptor which can then be used
    /// to display different kinds of cells in the same list.
    ///
    /// - Returns: ListCellDescriptor<AnyHashable>
    func any() -> ListCellDescriptor<AnyHashable, UITableViewCell> {
        var anyDescriptor = ListCellDescriptor<AnyHashable, UITableViewCell>(self.model,
                                                                             identifier: self.reuseIdentifier,
                                                                             cellClass: self.cellClass,
                                                                             configure: { cell in
                                                                                self.configure(cell as! CellType)
        })
        anyDescriptor.onSelect = onSelect
        anyDescriptor.onPerfromAction = onPerfromAction
        return anyDescriptor
    }

}

typealias AnyListCellDescriptor = ListCellDescriptor<AnyHashable, UITableViewCell>
typealias AnyListSectionDescriptor = ListSectionDescriptor<AnyHashable>

extension ListSectionDescriptor {

    /// Copies metaData from existing `sectionDescriptor` to produce `newSectionDescriptors`
    func insertReplacing(newItems: [ListCellDescriptor<T, UITableViewCell>]) -> ListSectionDescriptor {
        return ListSectionDescriptor(items: newItems, identifier: self.identifier)
    }

    /// Copies metaData from existing `sectionDescriptor` to produce `newSectionDescriptors`
    func insertReplacing(new: ListSectionDescriptor) -> ListSectionDescriptor {
        return ListSectionDescriptor(items: new.items, identifier: self.identifier)
    }

}

extension ListSectionDescriptor: Diffable {

    typealias InternalItemType = ListCellDescriptor<T, UITableViewCell>

    var diffHash: Int {
        return items.diffHash
    }

    var children: [ListCellDescriptor<T, UITableViewCell>] {
        return items
    }

}


extension ListCellDescriptor: Diffable { }

extension ListSectionDescriptor: CustomStringConvertible {

    var description: String {
        return "SEC { \(items) }"
    }

}


extension ListCellDescriptor: CustomStringConvertible {

    var description: String {
        return "CELL \(model.hashValue)"
    }

}
