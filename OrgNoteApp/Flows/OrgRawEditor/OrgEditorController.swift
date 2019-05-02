//
//  OrgEditorController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 5/2/19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit
import SwiftyParserCombinator

final class OrgEditorController: UIViewController {
    
    /// Input OrgFile to render or empty in case of new addition
    func display(_ orgFile: OrgFile?) {
        display(orgFile?.fileString)
    }
    
    /// Input raw string
    func display(_ orgString: String?) {
        textView.attributedText = highlighter.highlight(orgString ?? "")
    }
    
    /// Extract the org representation from currently rendered
    /// and user edited content.
    func extract() -> OrgFile? {
        guard let newOrgFile = self.textView.attributedText |> highlighter.plainText |> OrgParser.parse else {
            return inputOrgFile
        }
        return newOrgFile
    }
    
    func extract() -> String? {
        return self.textView.attributedText |> highlighter.plainText
    }
    
    public static func create(for orgFile: OrgFile?, using highlighter: HighlighterProtocol = OrgHighlighter(), rendering on: UITextView = UITextView()) -> OrgEditorController {
        let controller = OrgEditorController()
        controller.highlighter = highlighter
        controller.textView = on
        controller.inputOrgFile = orgFile
        controller.display(orgFile)
        return controller
    }
    
    private(set) var inputOrgFile: OrgFile!
    private(set) var highlighter: HighlighterProtocol!
    private(set) var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
        textView.delegate = self
    }
    
    private func setupTextView() {
        self.view.addSubview(textView)
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        [
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ].forEach { $0.isActive = true }
        setupTextViewAppearance()
    }
    
    private func setupTextViewAppearance() {
        self.textView.font = UIFont.preferredFont(forTextStyle: .body)
        self.textView.backgroundColor = .orgDarBackground
    }
    
}


extension OrgEditorController {
    
    func currentSelectionRange() -> Range<String.Index> {
        // just the new char pos. Not after
        let cursorPositon = max(textView.offset(from: textView.beginningOfDocument, to: textView.selectedTextRange!.start) - 1, 0)
        return Range<String.Index>.init(NSRange(location: cursorPositon, length: 0), in: textView.attributedText.string)!
    }
    
    func currentSelectionsHeadingDepth() -> Int? {
        let currentLineRange = textView.attributedText.string.lineRange(for: currentSelectionRange())
        let nsrange = rangeToNS(for: textView.attributedText.string, range: currentLineRange)
        let currentLine = textView.attributedText.attributedSubstring(from: nsrange)
        let currentLineWithoutFormat = OrgHighlighter().plainText(from: currentLine)
        let parsed = OrgParser().headingParser() |> run(currentLineWithoutFormat)
        return parsed.value()?.0.depth
    }
    
    func rangeToNS(for text: String, range: Range<String.Index>) -> NSRange {
        let lower = range.lowerBound.encodedOffset
        let upper = range.upperBound.encodedOffset
        return NSRange(location: lower, length: upper - lower)
    }
    
}


extension OrgEditorController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.attributedText.string
        
        // just the new char pos. Not after
        let cursorRange = currentSelectionRange()
        let lineRange = text.lineRange(for: cursorRange)
        let nslineRange = rangeToNS(for: text, range: lineRange)
        
        // unhighlight
        let stringToFormat = OrgHighlighter().plainText(from: textView.attributedText.attributedSubstring(from: nslineRange))
        
        // highlight
        let formatted = OrgHighlighter().highlight(stringToFormat)
        
        // set
        textView.textStorage.replaceCharacters(in: nslineRange, with: formatted)
        
        setupKeyboardShortcuts()
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        setupKeyboardShortcuts()
    }
    
}

extension OrgEditorController {
    
    private func setupKeyboardShortcuts() {
        textView.inputAccessoryView = nil
        let buttonToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let dismissItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hideKeyboard(_:)))
        buttonToolbar.items = [spaceItem] + headingInsertionButtons() + [dismissItem]
        textView.inputAccessoryView = buttonToolbar
        textView.reloadInputViews()
    }
    
    private func headingInsertionButtons() -> [UIBarButtonItem] {
        guard let depth = currentSelectionsHeadingDepth() else { return [] }
        let sameLevelStars = Array<String>.init(repeating: OrgHighlighter.Symbol.heading.rawValue, count: depth).joined()
        let subStars = sameLevelStars + OrgHighlighter.Symbol.heading.rawValue
        
        let addSubHeadingBelow = UIBarButtonItem.init(title: "››\(subStars)", style: .plain, target: self, action: #selector(addSubHeadingRightBelowCursor(_:)))
        let addHeadingBelow = UIBarButtonItem.init(title: "\(sameLevelStars)", style: .plain, target: self, action: #selector(addHeadingRightBelowCursor(_:)))
        
        if sameLevelStars.count > 1 {
            let parentStars = String(sameLevelStars.dropLast())
            let addParentHeadingBelow = UIBarButtonItem.init(title: "\(parentStars)‹‹", style: .plain, target: self, action: #selector(addParentHeadingRightBelowCursor(_:)))
            return [addParentHeadingBelow, addHeadingBelow, addSubHeadingBelow]
        } else {
            return [addHeadingBelow, addSubHeadingBelow]
        }
    }
    
    @objc private func addSubHeadingRightBelowCursor(_ button: UIBarButtonItem) {
        guard let depth = currentSelectionsHeadingDepth() else { return }
        addHeadingBelow(with: depth + 1)
    }
    
    private func addHeadingBelow(with depth: Int) {
        let starsAndSpace = "\n" + Array<String>.init(repeating: "*", count: depth).joined() + " "
        let currentCusorPos = currentSelectionRange()
        textView.textStorage.insert(OrgHighlighter().highlight(starsAndSpace), at: currentCusorPos.upperBound.encodedOffset + 1)
        let oldRange = rangeToNS(for: textView.attributedText.string, range: currentCusorPos)
        let newRange = NSRange(location: oldRange.location + starsAndSpace.count + 1, length: oldRange.length)
        textView.selectedRange = newRange
    }
    
    @objc private func addHeadingRightBelowCursor(_ button: UIBarButtonItem) {
        guard let depth = currentSelectionsHeadingDepth() else { return }
        addHeadingBelow(with: depth)
    }
    
    @objc private func addParentHeadingRightBelowCursor(_ button: UIBarButtonItem) {
        guard let depth = currentSelectionsHeadingDepth() else { return }
        addHeadingBelow(with: max(depth - 1, 0))
    }
    
    @objc private func hideKeyboard(_ item: UIBarButtonItem) {
        self.textView.resignFirstResponder()
    }
    
}
