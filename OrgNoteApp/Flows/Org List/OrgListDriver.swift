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
import DeclarativeTableView

typealias OutlineCellDesc = ListCellDescriptor<OutlineViewModel, OutlineCell>
typealias OutlineSectionDesc = ListSectionDescriptor<OutlineViewModel>


final class OrgListDriver {

    private var topLevelcellDescriptors: [AnyListCellDescriptor] {
        return self.backingOrgModel.outlines.map(OutlineViewModel.init).map(self.cellDescriptor)
    }

    // each top level cell is transformed to section
    var sections: [AnyListSectionDescriptor] {
        let topItems = self.backingOrgModel.flattenedSectionsRevelaingAllExpandedContainers().map { $0.map(OutlineViewModel.init).map(cellDescriptor) }
        return topItems.map(sectionDescriptor)
    }

    private var backingOrgModel: OrgFile

    // report back the model onExit
    private var onExit: (OrgFile) -> Void

    init(with orgModel: OrgFile, onExit: @escaping (OrgFile) -> Void) {
        self.backingOrgModel = orgModel
        self.onExit = onExit
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

    lazy var controller: ListViewController<AnyHashable> = {
        let actionsHandler = ListActionHandler(onExit: { [weak self] in
            guard let this = self else { return }
            this.onExit(this.backingOrgModel)
        }, onRefreshContents: nil)
        let temp = EditableListController(with: sections, actionsHandler: actionsHandler)
        return temp
    }()

    func perfromAction(_ action: ModelAction, on itemViewModel: OutlineViewModel) {
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
        generateNewSectionItemsWhenTappedOn(for: item) |> controller.update
    }

    func generateNewSectionItemsWhenTappedOn(for item: OutlineViewModel) -> [AnyListSectionDescriptor] {
        let mutated = item._backingModel.updateOnAllChildrensRecursively(isExapnded: !item.isExpanded)
        let immediateParent = self.backingOrgModel.immediateParent(ofFirst: item._backingModel)
        let newModel = self.backingOrgModel.replace(old: item._backingModel, with: mutated, childOf: immediateParent)
        self.backingOrgModel = newModel
        return self.sections
    }

}
