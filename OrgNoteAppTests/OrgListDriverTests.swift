//
//  OrgListDriverTests.swift
//  OrgNoteAppTests
//
//  Created by Vijaya Prakash Kandel on 15.06.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import XCTest
@testable import SwiftyParserCombinator
@testable import OrgNoteApp

final class OrgListDriverTests: XCTestCase {

    func test_whenOrgDriverConfiguresControllerWithSections() throws {
        let model = Mock.OrgFileService().fetchWorkLog().resultingValueIfSynchornous!.value!
        let modelTopLevelItemCount = model.count
        let configuredController = OrgListDriver(with: model).controller
        let controllerSectionCount = configuredController.sectionDescriptors.count
        XCTAssertEqual(modelTopLevelItemCount, controllerSectionCount)
    }

    /// We promote top level entries with min depthLevel to take section
    func test_orgDriverPromotesTopLevelOutlineToSectionDescriptors() {
        let orgModel = "* Hello\n** LeafNode\n* Hello Again\n** SecondNode\n*** leafNode\n* ThirdParent\n" |> OrgParser.parse

        let currentListSections = OrgListDriver(with: orgModel!).controller.sectionDescriptors
        XCTAssertEqual(currentListSections.count, 3)
    }

    func test_orgDriverPromotesTopLevelOutlineWithMinDepthLvelToSections() {
        let orgModel = "** Hello\n*** LeafNode\n** Hello Again\n*** SecondNode\n*** leafNode\n** ThirdParent\n" |> OrgParser.parse

        let currentListSections = OrgListDriver(with: orgModel!).controller.sectionDescriptors
        XCTAssertEqual(currentListSections.count, 3)

    }

    func test_whenGenerateNewSectionsIsTriggeredForLeafItem_thenItReturnsTheCurrentSectionsAsIs() {
        let orgModel = "* Hello\n** LeafNode" |> OrgParser.parse
        let listDriver = OrgListDriver(with: orgModel!)
        let currentListSections = listDriver.controller.sectionDescriptors
        let leafItem = orgModel!.first!.subItems.first! |> OutlineViewModel.init
        let newSections = listDriver.generateNewSectionItemsWhenTappedOn(item: leafItem, with: currentListSections)
        XCTAssertEqual(newSections, currentListSections)
    }

    func test_whenGenerateSectionsIsTriggeredForChildContainingItem_thenNewSetOfSectionsIsGenerated() {
        let orgModel = "* Hello\n** LeafNode" |> OrgParser.parse
        let listDriver = OrgListDriver(with: orgModel!)
        let currentListSections = listDriver.controller.sectionDescriptors
        let parentItem = orgModel!.first! |> OutlineViewModel.init
        let newSections = listDriver.generateNewSectionItemsWhenTappedOn(item: parentItem, with: currentListSections)
        XCTAssertNotEqual(newSections, currentListSections)
    }

}
