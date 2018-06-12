//
//  ArrayReplaceTest.swift
//  OrgNoteAppTests
//
//  Created by Vijaya Prakash Kandel on 12.06.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import XCTest
@testable import OrgNoteApp

final class ArrayReplaceTest: XCTestCase {

    func test_replacingOnEmptyArrayReturnsEmptyArray() {
        let arr = [Int]()
        let output = arr.replace(matching: 1, with: 0)
        XCTAssertTrue(output.isEmpty)
    }

    func test_replacingNonExistingItemWithNewOne_producesNoChanges() {
        let arr = [1,2]
        let output = arr.replace(matching: 3, with: 4)
        XCTAssertEqual(arr, output)
    }

    func test_whenSingleItemArrayIsReplaced_thenReturnedArrayIsSingleItem() {
        let arr = [true]
        let output = arr.replace(matching: true, with: false)
        XCTAssertEqual(arr.count, output.count)
        XCTAssertEqual(false, output.first!)
    }

    func test_whenItemsIdReplaced_thenCountOfArrayDoesnotChange() {
        let arr = [1,2,3,4]
        let output = arr.replace(matching: 2, with: 10)
        XCTAssertEqual(arr.count, output.count)
    }

    func test_thatReplaceAlgorithmIsLinear() {
        // TODO:
        // 1. Take 4 sets of (input, output)
        // 2. Measure time and analyse
    }

}
