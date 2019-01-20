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

    func flattenedSectionsRevelaingAllExpandedContainers() -> [[Outline]] {
        let topLevels = self.outlines
        let items = topLevels.map {
            $0.flattenAllExpanded
        }
        return items
    }

}


extension Outline {

    var flattenAllExpanded: [Outline] {
        let items = dfsFlatteningAllExpanded()
        return items
    }

    private func dfsFlatteningAllExpanded() -> [Outline] {
        if subItems.isEmpty || !isExpanded { return [self] }
        let all = [self] + subItems.flatMap { $0.dfsFlatteningAllExpanded() }
        return all
    }

}

