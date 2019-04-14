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
@testable import DeclarativeTableView

final class OrgListDriverTests: XCTestCase {

    func test_whenOrgDriverConfiguresControllerWithSections() throws {
        let model = Mock.OrgFileService().fetchWorkLog().resultingValueIfSynchornous!.value!
        let modelTopLevelItemCount = model.outlines.count
        let configuredController = OrgListDriver(with: model, onExit: {_ in}).controller
        let controllerSectionCount = configuredController.sectionDescriptors.count
        XCTAssertEqual(modelTopLevelItemCount, controllerSectionCount)
    }

    /// We promote top level entries with min depthLevel to take section
    func test_orgDriverPromotesTopLevelOutlineToSectionDescriptors() {
        let orgModel = "* Hello\n** LeafNode\n* Hello Again\n** SecondNode\n*** leafNode\n* ThirdParent\n" |> OrgParser.parse

        let currentListSections = OrgListDriver(with: orgModel!, onExit: { _ in }).controller.sectionDescriptors
        XCTAssertEqual(currentListSections.count, 3)
    }

    func test_orgDriverPromotesTopLevelOutlineWithMinDepthLvelToSections() {
        let orgModel = "** Hello\n*** LeafNode\n** Hello Again\n*** SecondNode\n*** leafNode\n** ThirdParent\n" |> OrgParser.parse

        let currentListSections = OrgListDriver(with: orgModel!, onExit: {_ in }).controller.sectionDescriptors
        XCTAssertEqual(currentListSections.count, 3)

    }

    func test_whenGenerateNewSectionsIsTriggeredForLeafItem_thenItReturnsTheCurrentSectionsAsIs() {
        let orgModel = "* Hello\n** LeafNode" |> OrgParser.parse
        let listDriver = OrgListDriver(with: orgModel!, onExit: {_ in })
        let currentListSections = listDriver.controller.sectionDescriptors
        let leafItem = orgModel!.outlines.first!.subItems.first! |> OutlineViewModel.init
        let newSections = listDriver.generateNewSectionItemsWhenTappedOn(for: leafItem)
        XCTAssertEqual(newSections, currentListSections)
    }

    func test_whenGenerateSectionsIsTriggeredForChildContainingItem_thenNewSetOfSectionsIsGenerated() {
        let orgModel = "* Hello\n** LeafNode" |> OrgParser.parse
        let listDriver = OrgListDriver(with: orgModel!, onExit: {_ in })
        let currentListSections = listDriver.controller.sectionDescriptors
        let parentItem = orgModel!.outlines.first! |> OutlineViewModel.init
        let newSections = listDriver.generateNewSectionItemsWhenTappedOn(for: parentItem)
        XCTAssertNotEqual(newSections[0], currentListSections[0])
    }

    func test_whenGeneratedSectionsContainExpandedItems_AndItIsTapped_thenSubItemsOfExpandedItemsAreCollapsed() {
        let orgModel = "* Hello\n** LeafNode" |> OrgParser.parse
        let listDriver = OrgListDriver(with: orgModel!, onExit: {_ in })
        let initialSections = listDriver.controller.sectionDescriptors
        let parentItem = orgModel!.outlines.first! |> OutlineViewModel.init
        listDriver.didSelect(item: parentItem)
        var expandedParentItem = parentItem
        expandedParentItem.isExpanded.toggle()
        listDriver.didSelect(item: expandedParentItem)
        XCTAssertEqual(listDriver.controller.sectionDescriptors, initialSections)
    }

    func test_whenNodeIsExpandedOn2Levles_thenParentIsTapped_thenEverythingIsCollapsed() {
        let orgModel = "* H1\n** H2\n*** H3" |> OrgParser.parse
        let listDriver = OrgListDriver(with: orgModel!, onExit: {_ in })
        let h1 = orgModel!.outlines.first! |> OutlineViewModel.init
        let h2 = orgModel!.outlines.first!.subItems.first! |> OutlineViewModel.init
        listDriver.didSelect(item: h1)
        listDriver.didSelect(item: h2)
        XCTAssertEqual(listDriver.controller.sectionDescriptors.first!.items.count, 3)
        let firstPrent = listDriver.controller.sectionDescriptors.first?.items.first?.model as! OutlineViewModel
        listDriver.didSelect(item: firstPrent)
        XCTAssertEqual(listDriver.controller.sectionDescriptors.first!.items.count, 1)
    }

}
