//
//  ListSection.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 13.05.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import UIKit

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

}

extension ListSectionDescriptor {

    init(with items: [ListCellDescriptor<T, UITableViewCell>]) {
        self.items = items
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
        return anyDescriptor
    }

}

typealias AnyListCellDescriptor = ListCellDescriptor<AnyHashable, UITableViewCell>
