//
//  OrgListEditInteractionCoordintaingController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 26.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit

struct OrgEditInteractionCoordinatingController {

    private func embedInPooverAndPresent(_ editController: BaseEditOutlineViewController, from controller: UIViewController) {
        let pop = PopoverController.create(embedding: editController)
        editController.onDone =  { [weak pop] in
            pop?.dismiss()
        }
        pop.modalPresentationStyle = .overFullScreen
        controller.present(pop, animated: true, completion: nil)
    }


    func performAction(_ action: OutlineAction, on itemViewModel: OutlineViewModel, currentModels: OrgFile, from controller: UIViewController, onCompletion: @escaping ((OrgFile) -> Void)) {
        let backingOrgModel = currentModels
        switch action {
        case .addItemBelow:
            let addItemController = AddOutlineViewController.create(childOf: itemViewModel._backingModel, entireModel: backingOrgModel, onCompletion: onCompletion)
            embedInPooverAndPresent(addItemController, from: controller)
        case .editItem:
            let immediateParentOfSelectedItem = backingOrgModel.immediateParent(ofFirst: itemViewModel._backingModel)
            let editItemController = EditOutlineViewController.create(childOf: immediateParentOfSelectedItem, edit: itemViewModel._backingModel, entireModel: backingOrgModel, onCompletion: onCompletion)
            embedInPooverAndPresent(editItemController, from: controller)
        case .deleteItem:
            let newModels: OrgFile
            if let immediateParent = backingOrgModel.immediateParent(ofFirst: itemViewModel._backingModel) {
                newModels = backingOrgModel.delete(itemViewModel._backingModel, childOf: immediateParent)
            } else {
                newModels = backingOrgModel.deleteRoot(itemViewModel._backingModel)
            }
            onCompletion(newModels)
        default:
            break
        }

    }

}
