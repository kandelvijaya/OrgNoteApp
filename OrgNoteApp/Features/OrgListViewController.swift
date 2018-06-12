//
//  WorkLogViewController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 01.06.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import Kekka


class OrgListFactoryTemp {



}


final class OrgListDriver {

    var cells: [AnyListCellDescriptor] {
        let model = Mock.OrgFileService().fetchWorkLog().resultingValueIfSynchornous!.value!
        return model.map(cellDescriptor)
    }

    private func cellDescriptor(for model: Outline) -> AnyListCellDescriptor {
        var cellDesc = ListCellDescriptor<Outline, OutlineCell>(model, identifier: "OutlineCell", cellClass: OutlineCell.self, configure: { cell in
            cell.update(with: model)
        })
        cellDesc.onSelect = {
            self.didSelect(item: model)
        }
        return cellDesc.any()
    }

    private func sectionDescriptor(for cellDescs: [AnyListCellDescriptor]) -> AnyListSectionDescriptor {
        return ListSectionDescriptor(with: cellDescs)
    }

    lazy var sections = [cells |> self.sectionDescriptor]
    lazy var controller = ListViewController(with: sections)

    func didSelect(item: Outline) {
        let currentListState = controller.sectionDescriptors

        let selected = currentListState.find { section in
            let givenItemFoundInThisSection = section.items.find { outline in
                outline.model == item as AnyHashable
            }
            return givenItemFoundInThisSection != nil
        }

        guard let selectedItemsSectionDescriptor = selected,
            let selectedItemCellDescriptor = selectedItemsSectionDescriptor.items.find({ $0.model == item as AnyHashable }) else {
            fatalError("A tapped item must correspond to current list of section")
        }

        let newItemChildCellDescriptors = item.subItems.map(cellDescriptor)

        let updatedSection = selectedItemsSectionDescriptor.items.replace(matching: selectedItemCellDescriptor, with: newItemChildCellDescriptors) |> sectionDescriptor

        let newSections = currentListState.replace(matching: selectedItemsSectionDescriptor, with: updatedSection)

        controller.update(with: newSections)
    }

}



typealias AnyListSectionDescriptor = ListSectionDescriptor<AnyHashable>

extension Array where Element: Equatable{

    func replace(matching old: Element, with new: [Element]) -> [Element] {
        guard let indexOfOld = firstIndex(where: { $0 == old }) else { return self }
        let firstHalf = Array(self[startIndex..<indexOfOld])
        let secondHalf = Array(self[indexOfOld...].dropFirst())
        let replacedSecondHalf = secondHalf + new
        return firstHalf + replacedSecondHalf
    }

    func replace(matching old: Element, with new: Element) -> [Element] {
        if new == old { return self }
        return replace(matching: old, with: [new])
    }

}

