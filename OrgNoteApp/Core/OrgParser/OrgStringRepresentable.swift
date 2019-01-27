//
//  OrgFileWriteToFile.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 14.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation

/// Conforming type should aim to represent plain text org mode structure
protocol OrgStringRepresentable {
    var fileString: String { get }
}


extension Array: OrgStringRepresentable where Element == Outline {

    var fileString: String {
        return map { $0.fileString }.joined(separator: "\n")
    }

}

extension OrgFile: OrgStringRepresentable {

    var fileString: String {
        let comments = self.topComments.joined(separator: "\n")
        let delimitter = self.topComments.isEmpty ? "" : "\n"
        return  comments + delimitter + self.outlines.fileString
    }

}



extension Outline: OrgStringRepresentable {

    /// Returns the Outline as it would be represented in plain text.
    /// Doesnt care to place `\n` newline at the front and back. This is the task of the OrgFile.
    var fileString: String {
        let newLine = "\n"
        let headingText = self.heading.fileString
        let contentText = content.map { return $0.isEmpty ? "\n" : "\($0)\n"  }.joined()
        let contentTextRemovingLastNewLine = contentText.hasSuffix(newLine) ? String(contentText.dropLast()): contentText
        let contentTextAligned = contentText.isEmpty ? "" : newLine + contentTextRemovingLastNewLine
        let subItemsText = subItems.fileString
        let subItemsTextAligned = subItemsText.isEmpty ? "" : newLine + subItemsText
        return headingText + contentTextAligned + subItemsTextAligned
    }

}


extension OutlineHeading: OrgStringRepresentable {

    var fileString: String {
        let space = " "
        let headingDepthStars = "*".replicate(depth) + space
        return headingDepthStars + title
    }

}

