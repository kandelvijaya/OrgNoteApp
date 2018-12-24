//
//  OrgEditViewController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 24.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit
import Kekka


final class AddOutlineViewController: UIViewController {

    private var immediateParent: Outline!
    private var entireModel: OrgFile!
    private var onCompletion: ((OrgFile) -> Void)!

    static func create(childOf: Outline, entireModel: OrgFile, onCompletion: @escaping ((OrgFile) -> Void)) -> AddOutlineViewController {
        let controller = UIStoryboard(name: "EditOrgViewController", bundle: Bundle.main).instantiateInitialViewController() as! AddOutlineViewController
        controller.immediateParent = childOf
        controller.entireModel = entireModel
        controller.onCompletion = onCompletion
        return controller
    }
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var headingTextField: UITextField!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    

    @IBAction func cancel(_ sender: Any) {
        // no changes saved
        onCompletion(entireModel)
    }

    @IBAction func done(_ sender: Any) {
        guard let toAdd = newOutline() else {
            // error report
            onCompletion(entireModel)
            return
        }
        let entireModelAfterAdding = entireModel.add(toAdd, childOf: immediateParent)
        onCompletion(entireModelAfterAdding)
    }

    private func newOutline() -> Outline? {
        let headingContent = headingTextField.text ?? ""
        let headingDepth = immediateParent.heading.depth + 1
        let headingText = "*".replicate(headingDepth) + " " + headingContent

        // contentTextField should be formatted properly
        // This is enforced by using org moded TextField later on
        let contentText = contentTextView.text ?? ""
        let entireText = headingText + "\n" + contentText
        let orgf = entireText |> OrgParser.parse
        return orgf?.first
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        stylize()
    }

    private func stylize() {
        [headingLabel, contentLabel].forEach {
            $0?.textColor = Theme.blueish.normal
        }
        contentTextView.textColor = Theme.blueish.text
        headingTextField.textColor = Theme.blueish.text

        cancelButton.tintColor = Theme.blueish.attention
        doneButton.tintColor = Theme.blueish.buttonTint
    }


}
