//
//  FullScreenOrgEditorController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 21.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import UIKit

final class FullScreenOrgRawEditorController: UIViewController {

    private var onDismiss: ((OrgFile?) -> Void)!
    private(set) var editor: OrgEditorController!
    @IBOutlet weak var editorContrinaer: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    static func create(input orgFile: OrgFile, onDismiss: @escaping (OrgFile?) -> Void) -> FullScreenOrgRawEditorController {
        let vc = UIStoryboard(name: String(describing: FullScreenOrgRawEditorController.self), bundle: Bundle(for: FullScreenOrgRawEditorController.self)).instantiateViewController(withIdentifier: String(describing: FullScreenOrgRawEditorController.self)) as! FullScreenOrgRawEditorController
        vc.onDismiss = onDismiss
        let editor = OrgEditorController.create(for: orgFile, using: OrgHighlighter())
        vc.editor = editor
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupEditor()
        setupKeyboardNotification()
    }
    
    private func setupEditor() {
        self.addChild(editor)
        editor.view.frame = editorContrinaer.bounds
        editor.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        editorContrinaer.addSubview(editor.view)
        editor.didMove(toParent: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onDismiss?(editor.extract())
    }
    
    // MARK:- Keyboard specifics
    
    private func setupKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardAnimationTime: Double = notification.userInfo?["UIKeyboardAnimationDurationUserInfoKey"] as? Double,
            let keyboardEndFrame: CGRect = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect,
            let keyboardBeginFrame: CGRect = notification.userInfo?["UIKeyboardFrameBeginUserInfoKey"] as? CGRect else {
                return
        }
        let verticalDistance: CGFloat = keyboardBeginFrame.origin.y - keyboardEndFrame.origin.y
        if verticalDistance == 0 {
            // keyboard was already there, might have been input accessory view redraw. Dont do anything.
            return
        }
        let safeBottomInsetThatKeyboardDoesnotUse: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
        let applicableVerticalDistance: CGFloat = verticalDistance - safeBottomInsetThatKeyboardDoesnotUse
        UIView.animate(withDuration: keyboardAnimationTime) {
            self.bottomConstraint.constant = -applicableVerticalDistance
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let keyboardAnimationTime: Double = notification.userInfo?["UIKeyboardAnimationDurationUserInfoKey"] as? Double else { return }
        UIView.animate(withDuration: keyboardAnimationTime) {
            self.bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
}
