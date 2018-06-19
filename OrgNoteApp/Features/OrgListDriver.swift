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
typealias OutlineSectionDesc = ListSectionDescriptor<OutlineViewModel, OutlineCell>

final class OrgListDriver {

    var cells: [OutlineCellDesc] {
        let model = Mock.OrgFileService().fetchWorkLog().resultingValueIfSynchornous!.value!
        return model.map(OutlineViewModel.init).map(cellDescriptor)
    }

    private func cellDescriptor(for viewModel: OutlineViewModel) -> OutlineCellDesc {
        var cellDesc = OutlineCellDesc(viewModel, identifier: "OutlineCell", cellClass: OutlineCell.self, configure: { cell in
            cell.update(with: viewModel)
        })
        cellDesc.onSelect = {
            self.didSelect(item: viewModel)
        }
        return cellDesc
    }



    private func sectionDescriptor(for cellDescs: [OutlineCellDesc]) -> OutlineSectionDesc {
        return ListSectionDescriptor(with: cellDescs)
    }

    lazy var sections = [cells |> self.sectionDescriptor]
    lazy var controller = ListViewController(with: sections)

    func didSelect(item: OutlineViewModel) {
        let currentListState = controller.sectionDescriptors

        let selected = currentListState.find { section in
            let givenItemFoundInThisSection = section.items.find { outline in
                outline.model == item
            }
            return givenItemFoundInThisSection != nil
        }

        guard let selectedItemsSectionDescriptor = selected,
            let selectedItemCellDescriptor = selectedItemsSectionDescriptor.items.find({ $0.model == item }) else {
            fatalError("A tapped item must correspond to current list of section")
        }

        if item.isExpanded {
            // collapse
            // remove all
            // find all subItems for this cells
            let subItemsCellDescriptors = findCellDescriptors(for: item.subModels, in: selectedItemsSectionDescriptor)
            let newCellDescriptors = deletingCellDescriptors(subItemsCellDescriptors, from: selectedItemsSectionDescriptor)
            let newSectionDescriptor = newCellDescriptors |> sectionDescriptor
            controller.update(with: newSectionDescriptor)
        } else {
            var newModel = item
            newModel.isExpanded = true

            let modifiedSelectedItemCell = newModel |> cellDescriptor

            let newItemChildCellDescriptors = item.subModels.map(cellDescriptor)

            let newAdded = selectedItemsSectionDescriptor.items.insert(items: newItemChildCellDescriptors, after: selectedItemCellDescriptor)
            let oldReplaced = newAdded.replace(matching: selectedItemCellDescriptor, with: modifiedSelectedItemCell)

            let updatedSection = oldReplaced |> sectionDescriptor

            let newSections = currentListState.replace(matching: selectedItemsSectionDescriptor, with: updatedSection)

            controller.update(with: newSections)
        }
    }

}

extension OrgListDriver {

    func findCellDescriptors(for items: [OutlineViewModel], in section: ListSectionDescriptor<OutlineViewModel>) -> [ListCellDescriptor<OutlineViewModel, UITableViewCell>] {
        let cellDescs = items.map(cellDescriptor)
        var newSection = section

    }

    func deletingCellDescriptor(_ items: [ListCellDescriptor<OutlineViewModel, UITableViewCell>], from section: ListSectionDescriptor<OutlineViewModel>) {

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

