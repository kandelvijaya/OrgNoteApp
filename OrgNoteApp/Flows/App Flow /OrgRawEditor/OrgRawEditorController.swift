//
//  OrgRawEditorController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 21.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import UIKit

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
    }

    private func customizeTextView() {
        self.textView.font = UIFont.preferredFont(forTextStyle: .body)
        self.textView.backgroundColor = .black
        self.textView.textColor = .white
    }

    private func setOrgFileInTextView() {
        let orgFileContents = orgFile.fileString
        textView.text = orgFileContents
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let newOrgFile = self.textView.text.flatMap(OrgParser.parse)
        if (newOrgFile?.fileString ?? "").isEmpty && !self.textView.text.isEmpty && !self.orgFile.fileString.isEmpty {
            /// something went wrong
            onDismiss(orgFile)
            return 
        }
        onDismiss(newOrgFile)
    }

}
