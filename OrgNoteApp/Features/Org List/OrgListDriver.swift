//
//  WorkLogViewController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 01.06.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import Kekka

typealias OutlineCellDesc = ListCellDescriptor<OutlineViewModel, OutlineCell>
typealias OutlineSectionDesc = ListSectionDescriptor<OutlineViewModel>


final class OrgListDriver {

    private var topLevelcellDescriptors: [AnyListCellDescriptor] = []

    init(with orgModel: OrgFile) {
        self.topLevelcellDescriptors = orgModel.map(OutlineViewModel.init).map(self.cellDescriptor)
    }

    private func cellDescriptor(for viewModel: OutlineViewModel) -> AnyListCellDescriptor {
        var cellDesc = OutlineCellDesc(viewModel, identifier: "OutlineCell", cellClass: OutlineCell.self, configure: { cell in
            cell.update(with: viewModel)
        })
        cellDesc.onSelect = {
            self.didSelect(item: viewModel)
        }
        return cellDesc.any()
    }

    private func sectionDescriptor(with cellDescs: [AnyListCellDescriptor]) -> AnyListSectionDescriptor {
        return ListSectionDescriptor(with: cellDescs)
    }

    // each top level cell is transformed to section
    lazy var sections = topLevelcellDescriptors.map { [$0] }.map(sectionDescriptor)
    lazy var controller = ListViewController(with: sections)

    func didSelect(item: OutlineViewModel) {
        generateNewSectionItemsWhenTappedOn(item: item, with: controller.sectionDescriptors) |> controller.update
    }


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
    func generateNewSectionItemsWhenTappedOn(item: OutlineViewModel, with currentSections: [AnyListSectionDescriptor]) -> [AnyListSectionDescriptor] {

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
            let newSectionAfterCollapsing = removingAllNestedSubItems(for: item, from: selectedItemsSectionDesc)
            let toggledItems = newSectionAfterCollapsing.items.replace(matching: selectedItemsCellDesc, with: toggledCellDescriptor(for: item))
            let toggledSections = toggledItems |> sectionDescriptor
            let newSections = currentListState.replace(matching: selectedItemsSectionDesc, with: toggledSections)
            return newSections
        } else {
            // Adds all subItems descriptor to this section descriptor
            // expands
            let modifiedSelectedItemCell = toggledCellDescriptor(for: item)

            let newItemChildCellDescriptors = item.subModels.map(cellDescriptor)

            let newAdded = selectedItemsSectionDesc.items.insert(items: newItemChildCellDescriptors, after: selectedItemsCellDesc)
            let oldReplaced = newAdded.replace(matching: selectedItemsCellDesc, with: modifiedSelectedItemCell)

            let updatedSection = selectedItemsSectionDesc.updated(with: oldReplaced)

            let newSections = currentListState.replace(matching: selectedItemsSectionDesc, with: updatedSection)

            return newSections
        }
    }

}

extension OrgListDriver {

    func findCellDescriptors(for items: [OutlineViewModel], in section: AnyListSectionDescriptor) -> [(Int, AnyListCellDescriptor)] {
     return []

    }

    func deletingCellDescriptor(_ items: [ListCellDescriptor<OutlineViewModel, UITableViewCell>], from section: ListSectionDescriptor<OutlineViewModel>) {

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


extension Array where Element: Equatable {

    /**
     Replaces `old` item with `new` items.
     - Complexity:- O(n) where n is the length of array being replaced on.
     */
    func replace(matching old: Element, with new: [Element]) -> [Element] {
        guard let indexOfOld = firstIndex(where: { $0 == old }) else { return self }
        let range = Range(uncheckedBounds: (lower: indexOfOld, upper: indexOfOld.advanced(by: 1)))
        var selfCopy = self
        selfCopy.replaceSubrange(range, with: new)
        return selfCopy
    }

    func replace(matching old: Element, with new: Element) -> [Element] {
        return replace(matching: old, with: [new])
    }

    func insert(items: [Element], after item: Element) -> [Element] {
        guard let indexOfItem = self.firstIndex(where: { $0 == item }) else { return self }
        var selfCopy = self
        selfCopy.insert(contentsOf: items, at: indexOfItem.advanced(by: 1))
        return selfCopy
    }

}


extension Array {
    func find(where precodition: (Element) -> Bool) -> Element? {
        for index in self {
            if precodition(index) {
                return index
            }
        }
        return nil
    }
}


extension Int {

    static func random(fittingSize: Int) -> Int {
        return Int.random(in: ClosedRange(uncheckedBounds: (lower: 0, upper: fittingSize)))
    }

}

