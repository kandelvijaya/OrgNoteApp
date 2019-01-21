//
//  OutlineViewModel.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 18.06.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit

struct OutlineViewModel: Hashable {

    let title: String
    let content: String
    let subModels: [OutlineViewModel]

    /// Making storage in sync with viewModel
    var isExpanded: Bool {
        get {
            return self._backingModel.isExpanded
        }

        set {
            self._backingModel.isExpanded = newValue
        }
    }

    let indentationLevel: Int
    var _backingModel: Outline

    init(with outline: Outline) {
        self.title = "✦ " + outline.heading.title
        self.content = outline.content.joined(separator: "\n")
        self.subModels = outline.subItems.map(OutlineViewModel.init)
        self.indentationLevel = outline.heading.depth
        self._backingModel = outline
    }

    var indicativeBackgroundColor: UIColor {
        // TODO:- Emit range of color based on content size or characterstics
        let materialBlue = UIColor(displayP3Red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 0.3)
        let materialWhite = UIColor(displayP3Red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 0.3)
        return self.isExpanded && !self._backingModel.subItems.isEmpty ?  materialBlue : materialWhite
    }

}

extension OutlineViewModel: Equatable {

    static func ==(_ lhs: OutlineViewModel, _ rhs: OutlineViewModel) -> Bool {
        return lhs.title == rhs.title && lhs.content == rhs.content && lhs.subModels == rhs.subModels
    }
    
}
