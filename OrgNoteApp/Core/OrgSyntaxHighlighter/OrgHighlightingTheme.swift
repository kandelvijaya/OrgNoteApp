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
    let stylingDict: [String: [NSAttributedString.Key: Any]]

}

let todoStylized =  [NSAttributedString.Key.foregroundColor: UIColor.yellow.cgColor, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .heavy)] as [NSAttributedString.Key : Any]
let defaultReplaceMentDict = ["TODO": todoStylized]

let defaultColoringTheme = OrgHighlightingTheme(normalFontSize: 18, stylingDict: defaultReplaceMentDict)
