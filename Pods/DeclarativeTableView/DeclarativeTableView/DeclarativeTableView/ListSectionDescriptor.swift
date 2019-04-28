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
public struct ListSectionDescriptor<T: Hashable>: Hashable {

    //TODO: Why does [ListCellDescriptor<T, UITableViewCell>] not have default hashValue
    public var hashValue: Int {
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

    public let items: [ListCellDescriptor<T, UITableViewCell>]
    public let footerText: String? = nil
    public let identifier: Int

}

extension ListSectionDescriptor {

    public init<U>(with items: [ListCellDescriptor<T, U>]) where U: UITableViewCell {
        let intItems = items.map { $0.rightFixed() }
        self.items = intItems
        self.identifier = 0
    }

}


public extension ListSectionDescriptor {

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

    public typealias InternalItemType = ListCellDescriptor<T, UITableViewCell>

    public var diffHash: Int {
        return items.diffHash
    }

    public var children: [ListCellDescriptor<T, UITableViewCell>] {
        return items
    }

}

extension ListSectionDescriptor: CustomStringConvertible {

    public var description: String {
        return "SEC { \(items) }"
    }

}


extension ListSectionDescriptor {
    
    /// converts a typed section into untyped section
    /// useful to have erased type when creating heterogeneous list
    public func any() -> ListSectionDescriptor<AnyHashable> {
        let items = self.items.map { $0.any() }
        let section = ListSectionDescriptor<AnyHashable>.init(items: items, identifier: self.identifier)
        return section
    }
    
}
