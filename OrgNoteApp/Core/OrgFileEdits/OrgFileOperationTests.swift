//
//  OrgFileOperationTests.swift
//  OrgNoteAppTests
//
//  Created by Vijaya Prakash Kandel on 18.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import XCTest
@testable import OrgNoteApp
import Kekka

final class OrgFileOperationTests: XCTestCase {

    private let outlineText = "* H1\n ** H2\nContent"
    private let outlineText2 = "* H1 another"

    // MARK:- Add

    func test_givenEmptyOrgFile_insertAtRootWorks() {
        let emptyOrg = [Outline]()
        let outline = outlineText |> OrgParser.parse
        let result = emptyOrg.addAtRoot(outline!.outlines.first!)
        XCTAssertEqual(result.fileString, outlineText)
    }

    func test_givenNonEmptyOrgFile_insertAtRootWorks() {
        let emptyOrg = [Outline]()
        let outline = outlineText |> OrgParser.parse
        let outline2 = outlineText2 |> OrgParser.parse
        let result = emptyOrg.addAtRoot(outline!.outlines.first!)
        let result2 = result.addAtRoot(outline2!.outlines.first!)
        XCTAssertEqual(result2.fileString, outlineText + "\n" + outlineText2)
    }

    func test_givenOrgFileWith1RootNode_insertionAsChildWorks() {
        let root = (outlineText |> OrgParser.parse)!.outlines.first!
        let subNode = "** H2\nContent" |> outline
        let result = [Outline]().addAtRoot(root)
        let addedResult = result.add(subNode, childOf: root)
        XCTAssertEqual(addedResult.fileString, outlineText + "\n" + subNode.fileString)
    }

    func test_whenAddItemOfChildIsCalled_childIsNotPartOfTheEsistingOrgfile_thenItIsNotInserted() {
        let root = [Outline]()
        let newRoot = root.add("** H2" |> outline, childOf: "* H1" |> outline)
        XCTAssertEqual(newRoot, root)
        XCTAssertEqual(newRoot.isEmpty, true)
    }

    func test_whenItemIsTriedToAddAsChildWhileItIsSameLevel_ItCantBeAdded() {
        let root = [ "* H1" |> outline ]
        let newRoot = root.add("* Another H1" |> outline, childOf: root.first!)
        XCTAssertEqual(newRoot, root)
    }

    func test_whenItemIsTriedToAddAt3rdeLvel_ItIsPossible() {
        let graph = [ "* H1\n**H2 \n*** H3" |> outline]
        let expected = "* H1\n**H2 \n*** H3\n**** H4\n***** H5\n content"
        let root = "*** H3" |> outline
        let child = "**** H4\n***** H5\n content" |> outline
        let newGraph = graph.add(child, childOf: root)
        XCTAssertEqual(newGraph.fileString, expected)
    }

    // MARK:- Delete

    func test_whenItemIsDeletedFromRootLevel_thenItWorks() {
        let graph = ["* H1" |> outline].deleteRoot("* H1" |> outline)
        XCTAssertEqual(graph.count, 0)
    }

    func test_whenItemIsDeletedFrom1stLvel_thenItWorks() {
        let graph = ["* H1\n** H2" |> outline].delete("** H2" |> outline, childOf: "* H1\n** H2" |> outline)
        XCTAssertEqual(graph.fileString, "* H1")
    }

    func test_whenItemIsDeletedFrom2ndLvel_thenItWorks() {
        let graph = ["* H1\n** H2\n*** H3\n*** H3 again" |> outline].delete("*** H3" |> outline, childOf: "** H2\n*** H3\n*** H3 again" |> outline)
        XCTAssertEqual(graph.fileString, "* H1\n** H2\n*** H3 again")
    }

    func test_whenItemIsDeletedFrom3rdLevelWithNestedGraph_thenItWorks() {
        let graph = ["* H1\n** H2\n*** H3\n**** H4\n*** H3 again\n** H2 again\n*** H3 on H2 again" |> outline].delete("*** H3\n**** H4" |> outline, childOf: "** H2\n*** H3\n**** H4\n*** H3 again" |> outline)
        XCTAssertEqual(graph.fileString, "* H1\n** H2\n*** H3 again\n** H2 again\n*** H3 on H2 again")
    }

    // MARK:- edit

    func test_whenItemIsEditedOnTheFirstLevel_thenItWorks() {
        let graph = ["* H1\n** H2" |> outline].update(old: "** H2" |> outline, new: "** H2\nContent \n*** H3 some more" |> outline, childOf: "* H1\n** H2" |> outline)
        XCTAssertEqual(graph.fileString, "* H1\n** H2\nContent \n*** H3 some more")
    }

    func test_editCannotBeDoneWithDiferentLevelOutline() {
        let graph = ["* H1\n** H2" |> outline].update(old: "** H2" |> outline, new: "* H1 again \n** H2\nContent \n*** H3 some more" |> outline, childOf: "* H1\n** H2" |> outline)
        XCTAssertEqual(graph.fileString, "* H1\n** H2")

        let graph2 = ["* H1\n** H2" |> outline].update(old: "** H2" |> outline, new: "*** H2\nContent \n*** H3 some more" |> outline, childOf: "* H1\n** H2" |> outline)
        XCTAssertEqual(graph2.fileString, "* H1\n** H2")
    }

    private func outline(_ string: String) -> Outline {
        return (string |> OrgParser.parse)!.outlines.first!
    }


}
