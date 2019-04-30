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

