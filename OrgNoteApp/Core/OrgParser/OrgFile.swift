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
        return topLevels.map { $0.flattenAllExpanded }
    }

}


extension Outline {

    var flattenAllExpanded: [Outline] {
        return dfsFlatteningAllExpanded()
    }

    private func dfsFlatteningAllExpanded() -> [Outline] {
        if subItems.isEmpty || !isExpanded { return [self] }
        return subItems.flatMap { $0.dfsFlatteningAllExpanded() }
    }



}

