//
//  OrgListDriverInteractionHandler.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 16.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import Kekka


protocol OrgListDriverInteractionServiceProtocol {

    var cellDescriptor: (OutlineViewModel) -> AnyListCellDescriptor { get }
    var sectionDescriptor: ([AnyListCellDescriptor]) -> AnyListSectionDescriptor { get }

    func generateNewSectionItemsWhenTappedOn(_ item: OutlineViewModel, with currentSections: [AnyListSectionDescriptor]) -> [AnyListSectionDescriptor]

}

struct OrgListDriverInteractionHandler: OrgListDriverInteractionServiceProtocol {

    var cellDescriptor: (OutlineViewModel) -> AnyListCellDescriptor
    var sectionDescriptor: ([AnyListCellDescriptor]) -> AnyListSectionDescriptor

    /// Generates `[ListSectionDescriptor]` from OrgFile that the user has focused on.
    /// All top level headings is default to be focused.
    /// If a user taps on any those item, it creates a bunch of `[CellDescriptor]` including
    /// the item tapped + subItems it has. Then it packs into the `SectionDescriptor` and replaces
    /// old with the new.
    ///
    /// - Parameters:
    ///   - item: Item that was tapped on
    ///   - currentSections: Current used SectionDescriptors
    /// - Returns: SectionDescriptors that include subitems of the item tapped in the orginal
    func generateNewSectionItemsWhenTappedOn(_ item: OutlineViewModel, with currentSections: [AnyListSectionDescriptor]) -> [AnyListSectionDescriptor] {

        // When on leaf return as is.
        if item.subModels.isEmpty { return currentSections }

        let currentListState = currentSections

        // Complexity:- O(n.m)
        // Find subarray which contains given item inside.
        let selectedSectionDesc = currentListState.first { section in
            let givenItemFoundInThisSection = section.items.first { outline in
                outline.model as! OutlineViewModel == item
            }
            return givenItemFoundInThisSection != nil
        }

        // find model which contains given item
        // Complexity:- O(m)
        guard let selectedItemsSectionDesc = selectedSectionDesc,
            let selectedItemsCellDesc = selectedItemsSectionDesc.items.find(where: { ($0.model as! OutlineViewModel) == item }) else {
                fatalError("A tapped item must correspond to current list of section")
        }

        if item.isExpanded {
            // Remove all subItems descriptor from this section descriptor
            // collapses
            // Complexity:- O(depthOfExpandedItem. item'sCount^2 at each level)
            let newSectionAfterCollapsing = removingAllNestedSubItems(for: item, from: selectedItemsSectionDesc)
            let toggledItems = newSectionAfterCollapsing.items.replace(matching: selectedItemsCellDesc, with: toggledCellDescriptor(for: item))
            let toggledSections = toggledItems |> sectionDescriptor
            let newSections = currentListState.replace(matching: selectedItemsSectionDesc, with: toggledSections)
            return newSections
        } else {
            // Adds all subItems descriptor to this section descriptor
            // expands
            // Complexity:- O(n)
            let modifiedSelectedItemCell = toggledCellDescriptor(for: item)

            let newItemChildCellDescriptors = item.subModels.map(cellDescriptor)

            let newAdded = selectedItemsSectionDesc.items.insert(items: newItemChildCellDescriptors, after: selectedItemsCellDesc)
            let oldReplaced = newAdded.replace(matching: selectedItemsCellDesc, with: modifiedSelectedItemCell)

            let updatedSection = selectedItemsSectionDesc.updated(with: oldReplaced)

            let newSections = currentListState.replace(matching: selectedItemsSectionDesc, with: updatedSection)

            return newSections
        }
    }

    /**
     Recursively removes children associated with this item.
     - Complexity:- O(depth. depthItemsCount^2)
     - Note:- One way to improve the perfomance to O(depth.depthItemsCount)
     is to accumulate replace changes for a loop and call it at the end.
     In this instance we can effectively assume the items being removed are
     in the same locality therefor the accumulation range can be added and
     replacement can happen in 1 go. However, the worst case remains the same.
     */
    func removingAllNestedSubItems(for model: OutlineViewModel, from section: AnyListSectionDescriptor) -> AnyListSectionDescriptor {
        if model.subModels.isEmpty { return section }
        let toRemoveCells = model.subModels.map(cellDescriptor)
        var fromList = section.items
        // Complexity:- O(n^2)
        toRemoveCells.forEach { itemCellToRemove in
            let newList = fromList.replace(matching: itemCellToRemove, with: [])
            fromList = newList
        }

        // Improvement
        /**
         let replaceRequest = ReplaceRequest(from: fromList)
         toRemoveCells.forEach{ replaceRequst.replace($0, with: [])}
         replaceRequest.execute()
         */


        var sectionDesc = fromList |> sectionDescriptor
        /// Complexity:- O(n.m^2)
        model.subModels.forEach { subItem in
            let tempDesc = sectionDesc
            sectionDesc = removingAllNestedSubItems(for: subItem, from: tempDesc)
        }
        return sectionDesc
    }

    func toggledCellDescriptor(for item: OutlineViewModel) -> AnyListCellDescriptor {
        var itemCopy = item
        itemCopy.isExpanded.toggle()
        return itemCopy |> cellDescriptor
    }

    
}
