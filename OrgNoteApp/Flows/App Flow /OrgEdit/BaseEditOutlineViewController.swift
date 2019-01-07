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

class BaseEditOutlineViewController: UIViewController, StoryboardInitializable {

    var immediateParent: Outline?
    var onDone: (() -> Void)?

    static var storyboardName: String {
        return "EditOrgViewController"
    }

    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var headingTextField: UITextField!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!


    @IBAction func cancel(_ sender: Any) {
        defer { onDone?() }
        onCancel()
    }

    func onCancel() {
        //no-op
    }

    func onDone(with outline: Outline?) {
        //no-op
    }

    func itemHeadingDepth() -> Int {
        //must be subclassed
        return 0
    }

    @IBAction func done(_ sender: Any) {
        defer { onDone?() }
        onDone(with: newOutline())
    }

    private func newOutline() -> Outline? {
        let headingContent = headingTextField.text ?? ""
        let headingDepth = itemHeadingDepth()
        let headingText = "*".replicate(headingDepth) + " " + headingContent

        // contentTextField should be formatted properly
        // This is enforced by using org moded TextField later on
        let contentText = contentTextView.text ?? ""
        let entireText = headingText + "\n" + contentText
        let orgf = entireText |> OrgParser.parse
        return orgf?.outlines.first
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



