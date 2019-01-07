//
//  OrgFileOperation.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 18.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import Kekka

extension OrgFile {

    func immediateParent(ofFirst firstMatching: Outline) -> Outline? {
        return self.outlines.immediateParent(ofFirst: firstMatching)
    }

    func add(_ item: Outline, childOf: Outline) -> OrgFile {
        let added = self.outlines.add(item, childOf: childOf)
        return OrgFile(topComments: self.topComments, outlines: added)
    }

    func addAtRoot(_ item: Outline) -> OrgFile {
        return OrgFile(topComments: self.topComments, outlines: self.outlines.addAtRoot(item))
    }

    func deleteRoot(_ item: Outline) -> OrgFile {
        return OrgFile(topComments: self.topComments, outlines: self.outlines.deleteRoot(item))
    }

    func delete(_ item: Outline, childOf: Outline) -> OrgFile {
        return OrgFile(topComments: self.topComments, outlines: self.outlines.delete(item, childOf: childOf))
    }

    func update(old item: Outline, new newItem: Outline, childOf parent: Outline?) -> OrgFile {
        return OrgFile(topComments: self.topComments, outlines: self.outlines.update(old: item, new: newItem, childOf: parent))
    }

}

/// TODO:- The complexity can be reduced by copying the struct to class first
/// then convert back to stucts within the method body. Given searching is not needed. 
extension Array where Element == Outline {

    /// Adds a new `Outline` as child of given parent `Outline`
    ///
    /// - Parameters:
    ///   - item: new Outline
    ///   - childOf: Parent Outline. This is for sanity
    /// - Returns: New OrgFile
    /// - Complexity:- O(depthOfGraph*EachLevelWidth) kind of O(n^2)
    func add(_ item: Outline, childOf: Outline) -> [Outline] {
        if item.heading.depth > childOf.heading.depth {
            return self.map{ $0.insert(item: item, asChildOf: childOf) }
        } else {
            return self
        }
    }

    /// appends at root
    func addAtRoot(_ item: Outline) -> [Outline] {
        return self + [item]
    }

    /// Simple filtering
    func deleteRoot(_ item: Outline) -> [Outline] {
        return self.filter { $0 != item }
    }

    /// reverse of `add(_:_)`
    ///
    /// - Parameters:
    ///   - item: new Outline
    ///   - childOf: Parent Outline. This is for sanity
    /// - Returns: New OrgFile
    /// - Complexity:- O(depthOfGraph*EachLevelWidth) kind of O(n^2)
    func delete(_ item: Outline, childOf: Outline) -> [Outline] {
        if item.heading.depth > childOf.heading.depth {
            return self.map{ $0.delete(item: item, childOf: childOf) }
        } else {
            return self
        }
    }

    /// - Complexity:- O(depthOfGraph*EachLevelWidth) kind of O(n^2)
    func update(old item: Outline, new newItem: Outline, childOf parent: Outline?) -> [Outline] {
        /// This is the case when top level item needs edit
        guard let parent = parent else {
            if let oldIndex = self.lastIndex(where: { $0 == item }) {
                var copySelf = self
                copySelf[oldIndex] = newItem
                return copySelf
            } else {
                assertionFailure("The edited item is not the root item. In such case, provide immediateParent")
                return self
            }
        }

        guard item.heading.depth == newItem.heading.depth else { return self }
        guard item.heading.depth > parent.heading.depth else { return self }

        //1. Delete the old item
        let intermediate = self.delete(item, childOf: parent)

        //2. Delete the item from parent to get new parent
        let mutatedParent = parent.delete(item: item, childOf: parent)

        //3. add the new item as child of mutated parent
        return intermediate.add(newItem, childOf: mutatedParent)
    }

    func immediateParent(ofFirst firstMatching: Outline) -> Outline? {
        for item in self {
            if item.subItems.contains(firstMatching) {
                return item
            } else {
                if let innerMatch = item.subItems.immediateParent(ofFirst: firstMatching) {
                    return innerMatch
                }
            }
        }
        return nil
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

    func delete(item: Outline, childOf parent: Outline) -> Outline {
        if parent == self {
            var mutableSelf = self
            mutableSelf.subItems = mutableSelf.subItems.filter { $0 != item }
            return mutableSelf
        }

        if let parentIndex = self.subItems.index(where: { $0 == parent }) {
            var mutableSelf = self
            var mutableParent = parent
            mutableParent.subItems = parent.subItems.filter { $0 != item }
            mutableSelf.subItems[parentIndex] = mutableParent
            return mutableSelf
        } else {
            // this might be deeper level parent we are looking for
            var accumulatedSubItems: [Outline] = []
            for thisItem in self.subItems {
                accumulatedSubItems.append(thisItem.delete(item: item, childOf: parent))
            }
            var mutatedSelf = self
            mutatedSelf.subItems = accumulatedSubItems
            return mutatedSelf
        }
    }

}
