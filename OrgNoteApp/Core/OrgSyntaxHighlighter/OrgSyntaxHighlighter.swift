//
//  OrgSyntaxHighlighter.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 26.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit

protocol OrgSyntaxHighlighterProtocol {
    func highlight(input rawString: String, with theme: OrgHighlightingTheme) -> NSAttributedString
    func highlight(input rawString: String) -> NSAttributedString
}

extension OrgSyntaxHighlighterProtocol {

    func highlight(input rawString: String) -> NSAttributedString {
        return highlight(input: rawString, with: defaultColoringTheme)
    }

}



