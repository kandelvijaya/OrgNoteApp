//
//  OrgParserTests.swift
//  OrgNoteAppTests
//
//  Created by Vijaya Prakash Kandel on 13.05.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import XCTest
@testable import SwiftyParserCombinator
@testable import OrgNoteApp

final class OrgParserTests: XCTestCase {

    func test_thatASimpleOutlineHeadingCanBeParsed() {
        let heading = "* This is a heading level 1"
        let output = OrgParser.parse(heading)
        XCTAssertNotNil(output)
        XCTAssertEqual(output!.outlines.count, 1)
        let thisOutline = output!.outlines.first!
        let expectedHeading = OutlineHeading(title: "This is a heading level 1", depth: 1)
        let expectedOutline = Outline(heading: expectedHeading, content: [])
        XCTAssertEqual(thisOutline, expectedOutline)
    }

    func test_whenOrgFileIsProvided_thenItCanBeParsed() {
        guard let fileURL = Bundle(for: self.classForCoder).url(forResource: "WL", withExtension: "org") else {
            XCTFail("Org file not found")
            return
        }

        guard let fileContentBuffer = try? String(contentsOf: fileURL) else {
            XCTFail("File contents cannot be converted to String")
            return
        }

        let output = OrgParser.parse(fileContentBuffer)
        XCTAssertNotNil(output)
        XCTAssertGreaterThan(output!.outlines.count, 0)
    }

    func test_whenMinDepthIsLevel2_thenFileIsParsed() {
        let orgRaw = "** This is second level heading."
        let parsed = OrgParser.parse(orgRaw)!
        XCTAssertEqual(parsed.outlines.count, 1)
        XCTAssertEqual(parsed.outlines.first!.heading.fileString, orgRaw)
    }

    func test_whenDepth2ItemIsFirst_HasDepth4Items_thenItIsParsed() {
        let orgRaw = "** This is heading\n**** This is subheading\n**** This is next heading.\n** This is another heading at depth2"
        let parsed = OrgParser.parse(orgRaw)!
        XCTAssertEqual(parsed.outlines.count, 2)
        XCTAssertEqual(parsed.outlines[0].subItems.count, 2)
    }

    func test_whenFragmentedOrgNotesAreParsed_thenWePreserveTheOriginalOrdering() {
        let fragmented = """
        * This is the main Heading
        *** This is the outside living 3rd heading
        ********** This is that
        ** This is the second heading
        ** This is another second heading
        *** This is nested one
        """

        let parsed = OrgParser.parse(fragmented)!
        XCTAssertEqual(parsed.outlines[0].subItems.count, 3)
        XCTAssertEqual(parsed.outlines[0].subItems.first!.heading.fileString, "*** This is the outside living 3rd heading")
        XCTAssertEqual(parsed.outlines.fileString, fragmented)
    }

    func test_sanity() {
        let allExamples = Example.allCases
        for item in allExamples {
            XCTAssertEqual(OrgParser.parse(item.rawValue)!.outlines.fileString, item.rawValue)
        }
    }

    func test_headingWithLeadingSpacesAreNotParsedAsHeadingButAsContents() {
        let example = """
        * H1
            * H2
        * H1 Second
        """
        let orgfile = OrgParser.parse(example)!
        XCTAssertEqual(orgfile.outlines.count, 2)
        XCTAssertEqual(orgfile.outlines[0].subItems.count, 0)
        /// The above *H2 has leading spaces, which is not a valid Org-Mode heading but content
        XCTAssertEqual(orgfile.outlines[0].content.first!.trimLeadingTrailingWhitespacesFromLine,"* H2")
    }

    func test_whenSameLevel2ItemsCanBeParsed() {
        let child = "**** H4 \n**** H4 another" |> OrgParser.parse
        XCTAssertEqual(child!.outlines.count, 2)
    }

    func test_whenOrgNoteWithCommentsCanBeParsed() {
        let orgRaw = """
        #+This is a comment
        #+This is second comment

        * H1
        ** H2
        H2 Content
        """

        let parsed = OrgParser.parse(orgRaw)
        XCTAssertEqual(parsed!.topComments.count, 2)
        XCTAssertEqual(parsed!.outlines.fileString, """
        * H1
        ** H2
        H2 Content
        """)
    }

    func test_whenTwoHeadingsHaveSpaceBetweenThem_ItIsRespected() {
        let rawOrg = "* Heading1 \n something\nthat\n* H2"
        let parsed = OrgParser.parse(rawOrg)
        XCTAssertEqual(parsed!.outlines.fileString, rawOrg)
    }

    func test_whenSubContentHasNewlines_theyAreRespected() {
        let raw = "* H1\nHello\n\n\nThere"
        let parsed = OrgParser.parse(raw)
        XCTAssertEqual(parsed!.outlines.first!.content, ["Hello", "", "", "There"])
        XCTAssertEqual(parsed!.fileString, raw)
    }

    func test_whenOutlineWithSpaceAreParsed_thenNewLinesAreRespected() {
        let raw = "Hello there \n\nHow are you?"
        let parsed = OrgParser().contentParser() |> SwiftyParserCombinator.run(raw)
        let output = parsed.value()!.0
        XCTAssertEqual(output, ["Hello there ", "", "How are you?"])
    }

    func test_when2headingHaveLineBetweeenThem_thisLineIsRespected() {
        let heading =
        """
        * H1

        * H3
        """
        let parsed = OrgParser.parse(heading)
        XCTAssertEqual(parsed!.outlines.first!.content, [""])
        XCTAssertEqual(parsed!.fileString, heading)
    }

    func test_whenOrgFileHasSpacesAroundContentAndHeading_theyArePreserved_afterParsing_andWhileWritingBack() {
        let orgRaw =
        """
        * H1

        This is the content
        This is more

        This is after a space.


        * H1 again

        ** H3
        *H1 yet again
        """
        let parsed = OrgParser.parse(orgRaw)
        XCTAssertEqual(parsed!.fileString, orgRaw)
    }

}

extension String {

    var trimLeadingTrailingWhitespacesFromLine: String {
        return split(separator: "\n").map{ $0.trimmingCharacters(in: CharacterSet(charactersIn: " ")) }.joined(separator: "\n")
    }

}


fileprivate enum Example: String, CaseIterable {
    case example1 = """
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
    case example2 = """
    * B This is another heading H1 without content
    ** This is B's subheading
    - list item 1
    - list item 2
    """

    case example3 = """
    * This is the content line 1
    This is content line 2
    * B This is another heading H1 without content
    """

    case unindentedExample = """
    * This is a heading
            ** This is a subheading
            ** This is another
        * This is second heading
    ** This is nested
    """
}
