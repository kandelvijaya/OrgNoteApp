//
//  OrgFileWriteToFileTests.swift
//  OrgNoteAppTests
//
//  Created by Vijaya Prakash Kandel on 14.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import XCTest
import SwiftyParserCombinator
@testable import OrgNoteApp

final class OrgFileWriteToStringTests: XCTestCase {

    let title = "This is the main title"
    let line1 = "Line 1 content"
    let line2 = "Line 2 content"
    let title2 = "This is second level title"
    let titleAnother = "This is same level title"

    func test_whenSimpleHeadingCanBeWrittenToString() {
        let orgfile = [Outline(heading: OutlineHeading(title: title, depth: 1), content: [line1, line2])]
        XCTAssertEqual("* \(title)\n\(line1)\n\(line2)", orgfile.fileString)
    }

    func test_whenSingletonOutlineWithoutSubItemsIsStringRepresented_ItDoesnotHaveEmptyLinesAround() {
        let orgfile = [Outline(heading: OutlineHeading(title: title, depth: 1), content: [line1, line2])]
        XCTAssertEqual("* \(title)\n\(line1)\n\(line2)", orgfile.fileString)
    }

    func test_whenSingletonOutlineWithoutContentAndSubItemsIsStringRepresented_thenItDoesNotHaveNewLinesAround() {
        let sub = Outline(heading: OutlineHeading(title: titleAnother, depth: 2), content: [line2])
        let orgfile = [Outline(heading: OutlineHeading(title: title, depth: 1), content: [line1, line2], subItems: [sub])]
        XCTAssertEqual("* \(title)\n\(line1)\n\(line2)\n** \(titleAnother)\n\(line2)", orgfile.fileString)
    }

    /// Proof that we can parse the file.
    /// Proof that the parsed structure can be written ditto to file.
    /// Conversion complete.
    func test_multiItemOutlinesCanBeWrittenToString() {
        let orgFileStringContents =   """
                                * 2018/04/01 Task
                                ** Q1:
                                *** TODO: Work on Org Parser
                                - list item 1
                                - list item 2
                                *** This is H1 -> H2 -> H3
                                - list item H3
                                - list item H3 2
                                ** This is H1 -> H2Second
                                - list item 1 H2 second
                                - list item 2 H2 second
                                ** This is H1 -> H2 Three
                                - list item 1 H2 3
                                - list item 2 H2 3
                                *** This is H1 -> H2 4 -> H3
                                - list item 1
                                - list item 2
                                """

        let orgfile = OrgParser.parse(orgFileStringContents)!
        let representedString = orgfile.fileString
        XCTAssertEqual(orgFileStringContents, representedString)
    }

}

