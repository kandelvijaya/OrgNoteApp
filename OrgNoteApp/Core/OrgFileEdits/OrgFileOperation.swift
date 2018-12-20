//
//  OrgFileOperation.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 18.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import Kekka

extension Array where Element == Outline {


    /// Adds a new `Outline` as child of given parent `Outline`
    ///
    /// - Parameters:
    ///   - item: new Outline
    ///   - childOf: Parent Outline. This is for sanity
    /// - Returns: New OrgFile
    func add(_ item: Outline, childOf: Outline) -> OrgFile {
        if item.heading.depth > childOf.heading.depth {
            return self.map{ $0.insert(item: item, asChildOf: childOf) }
        } else {
            return self
        }
    }

    /// appends at root
    func addAtRoot(_ item: Outline) -> OrgFile {
        return self + [item]
    }

    func deleteRoot(_ item: Outline) -> OrgFile {
        return []
    }

    func delete(_ item: Outline, childOf: Outline) -> OrgFile {
        return []
    }

    func update(old item: Outline, new newItem: Outline) -> OrgFile {
        return []
    }

}


extension Outline {

    func insert(item: Outline, asChildOf parent: Outline) -> Outline {

        if parent == self {
            var mutableSelf = self
            mutableSelf.subItems.append(item)
            return mutableSelf
        }

        if let parentIndex = self.subItems.index(where: { $0 == parent }) {
            var mutableSelf = self
            var mutableParent = parent
            mutableParent.subItems.append(item)
            mutableSelf.subItems[parentIndex] = mutableParent
            return mutableSelf
        } else {
            // this might be deeper level parent we are looking for
            var accumulatedSubItems: [Outline] = []
            for thisItem in self.subItems {
                accumulatedSubItems.append(thisItem.insert(item: item, asChildOf: parent))
            }
            var mutatedSelf = self
            mutatedSelf.subItems = accumulatedSubItems
            return mutatedSelf
        }
    }

}
