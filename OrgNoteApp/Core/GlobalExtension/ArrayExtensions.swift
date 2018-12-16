//
//  ArrayExtensions.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 16.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {

    /**
     Replaces `old` item with `new` items.
     - Complexity:- O(n) where n is the length of array being replaced on.
     */
    func replace(matching old: Element, with new: [Element]) -> [Element] {
        guard let indexOfOld = firstIndex(where: { $0 == old }) else { return self }
        let range = Range(uncheckedBounds: (lower: indexOfOld, upper: indexOfOld.advanced(by: 1)))
        var selfCopy = self
        selfCopy.replaceSubrange(range, with: new)
        return selfCopy
    }

    func replace(matching old: Element, with new: Element) -> [Element] {
        return replace(matching: old, with: [new])
    }

    func insert(items: [Element], after item: Element) -> [Element] {
        guard let indexOfItem = self.firstIndex(where: { $0 == item }) else { return self }
        var selfCopy = self
        selfCopy.insert(contentsOf: items, at: indexOfItem.advanced(by: 1))
        return selfCopy
    }

}


extension Array {

    func find(where precodition: (Element) -> Bool) -> Element? {
        for index in self {
            if precodition(index) {
                return index
            }
        }
        return nil
    }
    
}
