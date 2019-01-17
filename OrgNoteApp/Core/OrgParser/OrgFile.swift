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

    init(heading: OutlineHeading, content: [String], subItems: [Outline] = []) {
        self.heading = heading
        self.content = content
        self.subItems = subItems
    }

}
