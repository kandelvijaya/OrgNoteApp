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
    @IBOutlet weak var editorContainer: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!

    private(set) var editor: OrgEditorController!

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

    /// Will discard if you try adding parent heading.
    private func newOutline() -> Outline? {
        let headingContent = headingTextField.text.flatMap { item -> String? in
            guard !item.isEmpty else { return nil }
            let headingDepth = itemHeadingDepth()
            return "*".replicate(headingDepth) + " " + item
        }
        let contentText: String = editor.extract() ?? ""
        let entireText = headingContent.map { $0 + "\n" + contentText } ?? contentText
        guard !entireText.isEmpty else { return nil }
        
        let orgf = entireText |> OrgParser.parse
        return orgf?.outlines.first
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        embedEditor()   // do this first
        stylize()
        editorContainer.layer.borderColor = UIColor.lightGray.cgColor
        editorContainer.layer.borderWidth = 0.5
    }
    
    private func embedEditor() {
        editor = OrgEditorController.create(for: nil, using: OrgHighlighter())
        addChild(editor)
        editorContainer.addSubview(editor.view)
        editor.view.frame = editorContainer.bounds
        editor.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        editor.didMove(toParent: self)
    }

    private func stylize() {
        [headingLabel, contentLabel].forEach {
            $0?.textColor = Theme.blueish.normal
        }
        editor.textView.backgroundColor = .white
        headingTextField.textColor = Theme.blueish.text

        cancelButton.tintColor = Theme.blueish.attention
        doneButton.tintColor = Theme.blueish.buttonTint
        headingTextField.font = UIFont.preferredFont(forTextStyle: .headline)
    }

}



