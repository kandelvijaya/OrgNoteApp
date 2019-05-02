//
//  EditOutlineController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 25.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit

final class EditOutlineViewController: BaseEditOutlineViewController {

    private var entireModel: OrgFile!
    private var modelToEdit: Outline!
    private var onCompletion: ((OrgFile) -> Void)!

    static func create(childOf: Outline?, edit: Outline, entireModel: OrgFile, onCompletion: @escaping ((OrgFile) -> Void)) -> EditOutlineViewController {
        let controller = EditOutlineViewController.create()
        controller.immediateParent = childOf
        controller.entireModel = entireModel
        controller.modelToEdit = edit
        controller.onCompletion = onCompletion
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUIWithToEditModel()
    }

    private func updateUIWithToEditModel() {
        headingTextField.text = modelToEdit.heading.title
        let content =  modelToEdit.fileString.split(separator: "\n").dropFirst().joined(separator: "\n")
        editor.display(content)
    }

    override func onCancel() {
        // nothing
    }

    override func itemHeadingDepth() -> Int {
        return modelToEdit.heading.depth
    }

    override func onDone(with outline: Outline?) {
        guard let newModel = outline else {
            // error report
            // TODO:- show a error toast animating from the top of the container view
            // Wait for it to be interacted before dismissing
            onCompletion(entireModel)
            return
        }

        let entireModelAfterAdding = entireModel.update(old: modelToEdit, new: newModel, childOf: immediateParent)
        onCompletion(entireModelAfterAdding)
    }

}
