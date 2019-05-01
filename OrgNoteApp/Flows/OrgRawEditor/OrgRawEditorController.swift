//
//  OrgRawEditorController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 21.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import UIKit
import Kekka

final class OrgRawEditorController: UIViewController {

    private var orgFile: OrgFile!
    private var onDismiss: ((OrgFile?) -> Void)!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    static func create(input orgFile: OrgFile, onDismiss: @escaping (OrgFile?) -> Void) -> OrgRawEditorController {
        let vc = UIStoryboard(name: String(describing: OrgRawEditorController.self), bundle: Bundle(for: OrgRawEditorController.self)).instantiateViewController(withIdentifier: String(describing: OrgRawEditorController.self)) as! OrgRawEditorController
        vc.orgFile = orgFile
        vc.onDismiss = onDismiss
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        customizeTextView()
        setOrgFileInTextView()
        textView.delegate = self
        setupKeyboardNotification()
        setupKeyboardShortcuts()
    }
    
    private func setupKeyboardShortcuts() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let dismissItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hideKeyboard(_:)))
            let dismissGroup = UIBarButtonItemGroup(barButtonItems: [dismissItem], representativeItem: nil)
            textView.inputAssistantItem.leadingBarButtonGroups = [dismissGroup]
        } else {
            let buttonToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
            let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            let buttonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hideKeyboard(_:)))
            buttonToolbar.items = [spaceItem, buttonItem]
            textView.inputAccessoryView = buttonToolbar
        }
    }
    
    @objc private func hideKeyboard(_ item: UIBarButtonItem) {
        self.textView.resignFirstResponder()
    }
    
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

    private func customizeTextView() {
        self.textView.font = UIFont.preferredFont(forTextStyle: .body)
        self.textView.backgroundColor = .orgDarBackground
    }

    private func setOrgFileInTextView() {
        let orgFileContents = orgFile.fileString
        textView.attributedText = OrgHighlighter().orgHighlight(orgFileContents)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let newOrgFile = self.textView.attributedText |> OrgHighlighter().plainText |> OrgParser.parse
        if (newOrgFile?.fileString ?? "").isEmpty && !self.textView.text.isEmpty && !self.orgFile.fileString.isEmpty {
            /// something went wrong
            onDismiss(orgFile)
            return 
        }
        onDismiss(newOrgFile)
    }

}


extension OrgRawEditorController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.attributedText.string
        
        // just the new char pos. Not after
        let cursorPositon = textView.offset(from: textView.beginningOfDocument, to: textView.selectedTextRange!.start) - 1
        let cursorRange = Range<String.Index>.init(NSRange(location: cursorPositon, length: 0), in: text)!
        let lineRange = text.lineRange(for: cursorRange)
        let nslineRange = rangeToNS(for: text, range: lineRange)
        
        // unhighlight
        let stringToFormat = OrgHighlighter().plainText(from: textView.attributedText.attributedSubstring(from: nslineRange))
        
        // highlight
        let formatted = OrgHighlighter().orgHighlight(stringToFormat)
        
        // set 
        textView.textStorage.replaceCharacters(in: nslineRange, with: formatted)
    }
    
    func rangeToNS(for text: String, range: Range<String.Index>) -> NSRange {
        let lower = range.lowerBound.encodedOffset
        let upper = range.upperBound.encodedOffset
        return NSRange(location: lower, length: upper - lower)
    }
    
}

