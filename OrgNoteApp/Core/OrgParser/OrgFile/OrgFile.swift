//
//  OrgFile.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 17.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation

struct OrgFile: Hashable {
    let topComments: [String]
    let outlines: [Outline]
}

struct OutlineHeading: Hashable {

    let title: String
    let depth: Int

}


struct Outline: Hashable {

    let heading: OutlineHeading
    let content: [String]
    var subItems: [Outline]
    var isExpanded = false

    init(heading: OutlineHeading, content: [String], subItems: [Outline] = []) {
        self.heading = heading
        self.content = content
        self.subItems = subItems
    }

}

extension OrgFile {

    /// - Complexity:- O(n+m) i.e. O(allVertexes)
    func flattenedSectionsRevelaingAllExpandedContainers() -> [[Outline]] {
        let topLevels = self.outlines
        let items = topLevels.map {
            $0.flattenAllExpanded
        }
        return items
    }

    func replace(old: Outline, with new: Outline, childOf parent: Outline?) -> OrgFile {
        if old == new { return self }
        let thisComments = self.topComments
        let thisOutlines = self.outlines
        let modifiedOutlines = thisOutlines.map { $0.replace(old: old, with: new, childOf: parent) }
        let orgFile = OrgFile(topComments: thisComments, outlines: modifiedOutlines)
        return orgFile
    }

}

extension Outline {

    var flattenAllExpanded: [Outline] {
        let items = dfsFlatteningAllExpanded()
        return items
    }

    /// - Complexity:- O(n+m) i.e. O(allVertexes)
    private func dfsFlatteningAllExpanded() -> [Outline] {
        if subItems.isEmpty || !isExpanded { return [self] }
        let all = [self] + subItems.flatMap { $0.dfsFlatteningAllExpanded() }
        return all
    }

    func updateOnAllChildrensRecursively(isExapnded expansion: Bool) -> Outline {
        if expansion {
            // user entered into finding details. Dont reveal everything
            var copy = self
            copy.isExpanded = expansion
            return copy
        } else {
            // user wants to hide this and all the lower level opened items
            let subItemsProper = self.subItems.map{ $0.updateOnAllChildrensRecursively(isExapnded: expansion) }
            var item = Outline(heading: self.heading, content: self.content, subItems: subItemsProper)
            item.isExpanded = expansion
            return item
        }

    }

}


extension Outline {

    /// - Complexity:- O(n+m) i.e. O(allVertexes)
    /// Memory complexity is worse. It replicates a lot of structs.
    /// Maybe graph is better in this instance.
    func replace(old: Outline, with new: Outline, childOf parent: Outline?) -> Outline {
        if old == new { return self }

        if let p = parent {
            if p == self {
                var parentCopy = p
                parentCopy.subItems = parentCopy.subItems.replace(matching: old, with: new)
                return parentCopy
            } else {
                var selfCopy = self
                selfCopy.subItems = selfCopy.subItems.map {
                    return $0.replace(old: old, with: new, childOf: parent)
                }
                return selfCopy
            }
        } else {
            // This is the top level item
            if old == self {
                return new
            } else {
                return self
            }
        }
    }

}
