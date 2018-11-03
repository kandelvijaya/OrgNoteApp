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

    var cells: [AnyListCellDescriptor] {
        let model = Mock.OrgFileService().fetchWorkLog().resultingValueIfSynchornous!.value!
        return model.map(OutlineViewModel.init).map(cellDescriptor)
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

    lazy var celled = cells.map { [$0] }
    lazy var sections = celled.map(sectionDescriptor)
    lazy var controller = ListViewController(with: sections)

    func didSelect(item: OutlineViewModel) {
        if item.subModels.isEmpty { return }

        let currentListState = controller.sectionDescriptors

        let selected = currentListState.first { section in
            let givenItemFoundInThisSection = section.items.first { outline in
                outline.model as! OutlineViewModel == item
            }
            return givenItemFoundInThisSection != nil
        }

        guard let selectedItemsSectionDescriptor = selected,
            let selectedItemCellDescriptor = selectedItemsSectionDescriptor.items.find(where: { ($0.model as! OutlineViewModel) == item }) else {
            fatalError("A tapped item must correspond to current list of section")
        }

        if item.isExpanded {
            let newSectionAfterCollapsing = removingAllNestedSubItems(for: item, from: selectedItemsSectionDescriptor)
            let toggledItems = newSectionAfterCollapsing.items.replace(matching: selectedItemCellDescriptor, with: toggledCellDescriptor(for: item))
            let toggledSections = toggledItems |> sectionDescriptor
            let newSections = currentListState.replace(matching: selectedItemsSectionDescriptor, with: toggledSections)
            controller.update(with: newSections)
        } else {
            let modifiedSelectedItemCell = toggledCellDescriptor(for: item)

            let newItemChildCellDescriptors = item.subModels.map(cellDescriptor)

            let newAdded = selectedItemsSectionDescriptor.items.insert(items: newItemChildCellDescriptors, after: selectedItemCellDescriptor)
            let oldReplaced = newAdded.replace(matching: selectedItemCellDescriptor, with: modifiedSelectedItemCell)

            let updatedSection = selectedItemsSectionDescriptor.updated(with: oldReplaced)

            let newSections = currentListState.replace(matching: selectedItemsSectionDescriptor, with: updatedSection)

            controller.update(with: newSections)
        }
    }

}

extension OrgListDriver {

    func findCellDescriptors(for items: [OutlineViewModel], in section: AnyListSectionDescriptor) -> [(Int, AnyListCellDescriptor)] {
     return []

    }

    func deletingCellDescriptor(_ items: [ListCellDescriptor<OutlineViewModel, UITableViewCell>], from section: ListSectionDescriptor<OutlineViewModel>) {

    }

    func removingAllNestedSubItems(for model: OutlineViewModel, from section: AnyListSectionDescriptor) -> AnyListSectionDescriptor {
        if model.subModels.isEmpty { return section }
        let toRemoveCells = model.subModels.map(cellDescriptor)
        var fromList = section.items
        toRemoveCells.forEach { itemCellToRemove in
            let newList = fromList.replace(matching: itemCellToRemove, with: [])
            fromList = newList
        }
        
        /// This takes O(n^2)
        var sectionDesc = fromList |> sectionDescriptor
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


extension Array where Element: Equatable{

    func replace(matching old: Element, with new: [Element]) -> [Element] {
        guard let indexOfOld = firstIndex(where: { $0 == old }) else { return self }
        let firstHalf = Array(self[startIndex..<indexOfOld])
        let secondHalf = Array(self[indexOfOld...].dropFirst())
        let replacedSecondHalf = new + secondHalf
        return firstHalf + replacedSecondHalf
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

