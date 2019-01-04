//
//  OrgHighlightingTheme.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 26.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit


struct OrgHighlightingTheme {

    let normalFontSize: CGFloat

    // attributes for matching word with
    let stylingDict: [String: [NSAttributedStringKey: Any]]

}

let todoStylized =  [NSAttributedStringKey.foregroundColor: UIColor.yellow.cgColor, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18, weight: .heavy)] as [NSAttributedStringKey : Any]
let defaultReplaceMentDict = ["TODO": todoStylized]

let defaultColoringTheme = OrgHighlightingTheme(normalFontSize: 18, stylingDict: defaultReplaceMentDict)
