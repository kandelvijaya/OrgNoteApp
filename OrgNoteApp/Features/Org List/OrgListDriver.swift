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
    lazy var controller = EditableListController(with: sections)

    func didSelect(item: OutlineViewModel) {
        generateNewSectionItemsWhenTappedOn(for: item, with: controller.sectionDescriptors) |> controller.update
    }

    func generateNewSectionItemsWhenTappedOn(for item: OutlineViewModel, with currentSections: [AnyListSectionDescriptor]) -> [AnyListSectionDescriptor] {
        let interactionHandler = OrgListDriverInteractionHandler(cellDescriptor: self.cellDescriptor, sectionDescriptor: self.sectionDescriptor)
        return interactionHandler.generateNewSectionItemsWhenTappedOn(item, with: currentSections)
    }

}
