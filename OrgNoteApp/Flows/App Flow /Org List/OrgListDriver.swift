//
//  WorkLogViewController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 01.06.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import Kekka
import FastDiff

typealias OutlineCellDesc = ListCellDescriptor<OutlineViewModel, OutlineCell>
typealias OutlineSectionDesc = ListSectionDescriptor<OutlineViewModel>


final class OrgListDriver {

    private var topLevelcellDescriptors: [AnyListCellDescriptor] {
        return self.backingOrgModel.outlines.map(OutlineViewModel.init).map(self.cellDescriptor)
    }

    // each top level cell is transformed to section
    var sections: [AnyListSectionDescriptor] {
        return topLevelcellDescriptors.map { [$0] }.map(sectionDescriptor)
    }

    private var backingOrgModel: OrgFile

    init(with orgModel: OrgFile) {
        self.backingOrgModel = orgModel
    }

    private func update(with newModel: OrgFile) {
        self.backingOrgModel = newModel
    }

    private func cellDescriptor(for viewModel: OutlineViewModel) -> AnyListCellDescriptor {
        var cellDesc = OutlineCellDesc(viewModel, identifier: "OutlineCell", cellClass: OutlineCell.self, configure: { cell in
            cell.update(with: viewModel)
        })
        cellDesc.onSelect = {
            self.didSelect(item: viewModel)
        }

        cellDesc.onPerfromAction = { action in
            self.perfromAction(action, on: viewModel)
        }

        return cellDesc.any()
    }

    private func sectionDescriptor(with cellDescs: [AnyListCellDescriptor]) -> AnyListSectionDescriptor {
        return ListSectionDescriptor(with: cellDescs)
    }

    lazy var controller = EditableListController(with: sections)

    func perfromAction(_ action: OutlineAction, on itemViewModel: OutlineViewModel) {
        let onCompletion = { [weak self] (newModel: OrgFile) in
            guard let this = self else { return }
            if this.backingOrgModel == newModel { return }

            this.update(with: newModel)
            DispatchQueue.main.async {
                this.controller.update(with: this.sections)
            }
        }
        OrgEditInteractionCoordinatingController().performAction(action, on: itemViewModel, currentModels: backingOrgModel, from: self.controller, onCompletion: onCompletion)
    }

    func didSelect(item: OutlineViewModel) {
        generateNewSectionItemsWhenTappedOn(for: item, with: controller.sectionDescriptors) |> controller.update
    }

    func generateNewSectionItemsWhenTappedOn(for item: OutlineViewModel, with currentSections: [AnyListSectionDescriptor]) -> [AnyListSectionDescriptor] {
        let interactionHandler = OrgListDriverInteractionHandler(cellDescriptor: self.cellDescriptor, sectionDescriptor: self.sectionDescriptor)
        return interactionHandler.generateNewSectionItemsWhenTappedOn(item, with: currentSections)
    }

}
