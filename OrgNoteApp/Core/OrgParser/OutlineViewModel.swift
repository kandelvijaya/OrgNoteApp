//
//  OutlineViewModel.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 18.06.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation

struct OutlineViewModel: Hashable {

    let title: String
    let content: String
    let subModels: [OutlineViewModel]
    var isExpanded: Bool = false
    let indentationLevel: Int

    init(with outline: Outline) {
        self.title = "✦ " + outline.heading.title
        self.content = outline.content.joined(separator: "\n")
        self.subModels = outline.subItems.map(OutlineViewModel.init)
        self.indentationLevel = outline.heading.depth
    }

}

extension OutlineViewModel: Equatable {

    static func ==(_ lhs: OutlineViewModel, _ rhs: OutlineViewModel) -> Bool {
        return lhs.title == rhs.title && lhs.content == rhs.content && lhs.subModels == rhs.subModels
    }
    
}
