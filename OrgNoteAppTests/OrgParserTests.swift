//
//  OrgParserTests.swift
//  OrgNoteAppTests
//
//  Created by Vijaya Prakash Kandel on 13.05.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import XCTest
@testable import ParserCombinator
@testable import OrgNoteApp

final class OrgParserTests: XCTestCase {

    func test_thatASimpleOutlineHeadingCanBeParsed() {
        let heading = "* This is a heading level 1"
        let output = OrgParser.parse(heading)
        XCTAssertNotNil(output)
        XCTAssertEqual(output!.count, 1)
        let thisOutline = output!.first!
        let expectedHeading = OutlineHeading(title: "This is a heading level 1", depth: 1)
        let expectedOutline = Outline(heading: expectedHeading, content: [])
        XCTAssertEqual(thisOutline, expectedOutline)
    }

}


let str =   """
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

let strWithSub =   """
* B This is another heading H1 without content
** This is B's subheading
- list item 1
- list item 2
"""
let strC =   """
This is the content line 1
This is content line 2
* B This is another heading H1 without content
"""
let strWithoutContent =  """
* This is the content line 1
This is content line 2
* B This is another heading H1 without content
"""


//let orgParsed = orgParser() |> many |> run(eventFileContent())
//orgParsed |> consoleOut
//
//orgParsed.value()?.0[0].heading.title
//orgParsed.value()?.0[1].subItems.count
