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
        let topItems = self.backingOrgModel.flattenedSectionsRevelaingAllExpandedContainers().map { $0.map(OutlineViewModel.init).map(cellDescriptor) }
        //return topLevelcellDescriptors.map { [$0] }.map(sectionDescriptor)
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
        let mutated = item._backingModel.updateExpansionOnAllChildrens(!item.isExpanded)
        let immediateParent = self.backingOrgModel.immediateParent(ofFirst: item._backingModel)
        let newModel = self.backingOrgModel.replace(old: item._backingModel, with: mutated, childOf: immediateParent)
        self.backingOrgModel = newModel
        return self.sections
    }

}


extension Outline {

    func updateExpansionOnAllChildrens(_ expansion: Bool) -> Outline {
        if expansion {
            // user entered into finding details. Dont reveal everything
            var copy = self
            copy.isExpanded = expansion
            return copy
        } else {
            // user wants to hide this and all the lower level opened items
            let subItemsProper = self.subItems.map{ $0.updateExpansionOnAllChildrens(expansion) }
            var item = Outline(heading: self.heading, content: self.content, subItems: subItemsProper)
            item.isExpanded = expansion
            return item
        }

    }

}

extension OrgFile {

    func replace(old: Outline, with new: Outline, childOf parent: Outline?) -> OrgFile {
        if old == new { return self }
        let thisComments = self.topComments
        let thisOutlines = self.outlines
        let modifiedOutlines = thisOutlines.map { $0.replace(old: old, with: new, childOf: parent) }
        let orgFile = OrgFile(topComments: thisComments, outlines: modifiedOutlines)
        return orgFile
    }

}

extension Outline {

    /// - Complexity:- O(n+m) i.e. O(allVertexes)
    /// Memory complexity is worse. It replicates a lot of structs.
    /// Maybe graph is better in this instance.
    func replace(old: Outline, with new: Outline, childOf parent: Outline?) -> Outline {
        if old == new { return self }

        if let p = parent {
            if p == self {
                var parentCopy = p
                parentCopy.subItems = parentCopy.subItems.replace(matching: old, with: new)
                return parentCopy
            } else {
                var selfCopy = self
                selfCopy.subItems = selfCopy.subItems.map {
                    return $0.replace(old: old, with: new, childOf: parent)
                }
                return selfCopy
            }
        } else {
            // This is the top level item
            return new
        }
    }

}
