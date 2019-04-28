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
        textView.isScrollEnabled = false
        let currentPosition = textView.selectedTextRange!.start
        let currentContentOffset = textView.contentOffset
        let cursorPositon = textView.offset(from: textView.beginningOfDocument, to: textView.selectedTextRange!.start)
        let cursorLine = findLine(on: cursorPositon, in: OrgHighlighter().plainText(from: textView.attributedText))
        let highlighted = OrgHighlighter().orgHighlight(cursorLine.1)
        let newStyled = replaceLine(old: textView.attributedText, with: highlighted, at: cursorPositon)
        textView.attributedText = newStyled
        // how to preseve the cursor at the same point
//        let position = textView.position(from: currentPosition, in: .right, offset: 0)!
        textView.selectedTextRange = textView.textRange(from: currentPosition, to: currentPosition)
        let rangeInText = (textView.attributedText.string as NSString).range(of: cursorLine.1)
        textView.contentOffset = currentContentOffset
        textView.isScrollEnabled = true
    }
    
    /// Interview Question: Given a string representing file and cursor position (char position), return the line that the cursor belongs to
    func findLineNumber(on cursorCount: Int, in text: String) -> Int {
        var currentLineNo: Int = 0
        for (index, item) in text.enumerated() {
            if index == cursorCount {
                break
            }
            if item == Character("\n") {
                currentLineNo += 1
            }
        }
        
        return currentLineNo
    }
    
    func findLine(on cursorPos: Int, in string: String) -> (Int, String) {
        let lineNo = findLineNumber(on: cursorPos, in: string)
        return (lineNo, String(string.split(separator: "\n", omittingEmptySubsequences: false)[lineNo]))
    }
    
    func replaceLine(old: NSAttributedString, with new: NSAttributedString, at cursorPos: Int) -> NSAttributedString {
        let lineInfo = findLine(on: cursorPos, in: old.string)
        /// this might be ambigious if the same line exists on top
        let oldRange = (old.string as NSString).range(of: lineInfo.1)
        guard oldRange.length > 0 else { return old }
        let oldCopy = NSMutableAttributedString.init(attributedString: old)
        oldCopy.replaceCharacters(in: oldRange, with: new)
        return oldCopy
    }
    
}

