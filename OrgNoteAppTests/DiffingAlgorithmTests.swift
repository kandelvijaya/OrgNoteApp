//
//  DiffingAlgorithmTests.swift
//  OrgNoteAppTests
//
//  Created by Vijaya Prakash Kandel on 13.05.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import XCTest
@testable import OrgNoteApp

extension Int: Diffable {}

final class DiffTests: XCTestCase {

    func test_whenDiffingWithExactSameItems_diffResultIsEmpty() {
        let input = [1,2,3]
        let nextInput = [1,2,3]
        let output = diff(input, nextInput)
        XCTAssertTrue(exceptUnchanged(output).isEmpty)
    }

    func test_whenDiffingWithDifferentItems_diffResultIsNotEmpty() {
        let input = [1,2,3]
        let new = [1,2,3,4]
        let output = diff(input, new)
        XCTAssertFalse(exceptUnchanged(output).isEmpty)
    }

    func test_whenSimpleDiffWithFirstAndSecondIndexSwapped_thenItProducesCorrectSequence() {
        let initial = [1,2,3]
        let new = [2,1,3]
        let output = exceptUnchanged(simpleDiff(initial, new))
        XCTAssertEqual(output, [DiffResult<Int>.deleted(item:1, fromIndex: 0),
                                .inserted(item:2, atIndex: 0),
                                .deleted(item:2, fromIndex: 1),
                                .inserted(item:1, atIndex: 1)])
    }

    func test_whenDiffWithFirstAndSecondIndexItemSwapped_thenItProducesItemMoved() {
        assertDiff(start: [1,2,3], new: [2,1,3],
                   resulting: [.moved(item: 1, fromIndex: 0, toIndex: 1),
                               .moved(item: 2, fromIndex: 1, toIndex: 0)])
    }

    func test_simpleDiffWhenLongerNewArray_thenBeyondItemsAreInserted() {
        assertDiff(start: [1,2,3], new: [1,2,3,4],
                   resulting: [DiffResult<Int>.inserted(item: 4, atIndex: 3)])
        assertSimpleDiff(start: [], new: [1,2], resulting: [.inserted(item:1, atIndex: 0),
                                                            .inserted(item: 2, atIndex: 1)])
        assertSimpleDiff(start: [1], new: [], resulting: [.deleted(item: 1, fromIndex: 0)])
        assertSimpleDiff(start: [1,2,3], new: [1], resulting: [.deleted(item: 2, fromIndex: 1),
                                                               .deleted(item: 3, fromIndex: 2)])
    }

    private func assertSimpleDiff<T>(start: [T], new: [T], resulting: [DiffResult<T>]) where T: Hashable {
        let output = exceptUnchanged(simpleDiff(start, new))
        XCTAssertEqual(output, resulting)
    }

    private func assertDiff<T>(start: [T], new: [T], resulting: [DiffResult<T>]) where T: Hashable {
        let output = exceptUnchanged(diff(start, new))
        XCTAssertEqual(output, resulting)
    }

    func test_whenSameItemsAreDiffed_everythingIsUnchanged() {
        let initial = [1,2,3]
        let new = [1,2,3]
        let output = simpleDiff(initial, new)
        XCTAssertEqual(output, [.unchanged(item: 1, atIndex: 0),
                                .unchanged(item:2, atIndex: 1),
                                .unchanged(item:3, atIndex:2)])
        let refinedDiff = diff(initial, new)
        XCTAssertEqual([], refinedDiff)
    }

}


func simpleDiff<T: Diffable>(_ old: [T], _ new: [T]) -> [DiffResult<T>] {
    let olds = old.enumerated().map { ($0.0, $0.1) }
    let news = new.enumerated().map { ($0.0, $0.1) }
    return _diffWithoutMove(olds, news)
}
