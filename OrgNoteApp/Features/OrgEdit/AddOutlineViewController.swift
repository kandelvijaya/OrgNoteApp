//
//  AddOutlineController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 25.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit

final class AddOutlineViewController: BaseEditOutlineViewController {

    private var entireModel: OrgFile!
    private var onCompletion: ((OrgFile) -> Void)!

    static func create(childOf: Outline, entireModel: OrgFile, onCompletion: @escaping ((OrgFile) -> Void)) -> AddOutlineViewController {
        let controller = AddOutlineViewController.create()
        controller.immediateParent = childOf
        controller.entireModel = entireModel
        controller.onCompletion = onCompletion
        return controller
    }

    override func onCancel() {
        // nothing
    }

    override func itemHeadingDepth() -> Int {
        assert(immediateParent != nil, "Can't add new item if the parent is unknown")
        return immediateParent!.heading.depth + 1
    }

    override func onDone(with outline: Outline?) {
        guard let newModel = outline else {
            // error report
            // TODO:- show a error toast animating from the top of the container view
            // Wait for it to be interacted before dismissing
            onCompletion(entireModel)
            return
        }
        let entireModelAfterAdding = entireModel.add(newModel, childOf: immediateParent!)
        onCompletion(entireModelAfterAdding)
    }

}
