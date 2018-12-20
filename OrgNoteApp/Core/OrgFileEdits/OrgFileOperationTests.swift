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

    private func unwrapped<T>(_ value: T?) -> T {
        return value!
    }

    func test_givenEmptyOrgFile_insertAtRootWorks() {
        let emptyOrg = [Outline]()
        let outline = outlineText |> OrgParser.parse
        let result = emptyOrg.addAtRoot(outline!.first!)
        XCTAssertEqual(result.fileString, outlineText)
    }

    func test_givenNonEmptyOrgFile_insertAtRootWorks() {
        let emptyOrg = [Outline]()
        let outline = outlineText |> OrgParser.parse
        let outline2 = outlineText2 |> OrgParser.parse
        let result = emptyOrg.addAtRoot(outline!.first!)
        let result2 = result.addAtRoot(outline2!.first!)
        XCTAssertEqual(result2.fileString, outlineText + "\n" + outlineText2)
    }

    func test_givenOrgFileWith1RootNode_insertionAsChildWorks() {
        let root = (outlineText |> OrgParser.parse)!.first!
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

    private func outline(_ string: String) -> Outline {
        return (string |> OrgParser.parse)!.first!
    }


}
