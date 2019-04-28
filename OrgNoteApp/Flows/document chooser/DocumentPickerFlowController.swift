//
//  DocumentPickerFlowController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 4/6/19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit

/// This comes from the info.plist file exported Document Types.
let kOrgFileType = "kandelvijaya.org"

final class DocumentPickerFlowController: UIDocumentBrowserViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.allowsDocumentCreation = true
        self.allowsPickingMultipleItems = false
    }
    
}

extension DocumentPickerFlowController: UIDocumentBrowserViewControllerDelegate {
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let firstURL = documentURLs.first else {
            assertionFailure("When document is picked there should be a url associated to it")
            return
        }
        let orgDocument = OrgDocument(fileURL: firstURL)
        orgDocument.open { (success) in
            if success {
                self.presentEditor(for: orgDocument.fileURL)
            } else {
                print("something went wrong")
            }
        }
    }
    
    private func presentEditor(for url: URL) {
        let orgFile = File(url: url)
        let controller = OrgViewEditCoordinatingController.created(with: orgFile, onExit: { [weak self] in
            // write back maybe
            self?.dismiss(animated: true, completion: nil)
        })
        
        // dismiss any other modals and present the new one
        dismiss(animated: true, completion: nil)
        show(wrappedInNav(controller), sender: self)
    }
    
    private func wrappedInNav(_ controller: UIViewController) -> UIViewController {
        let navController = UINavigationController(rootViewController: controller)
        return navController
    }
    
}


final class OrgDocument: UIDocument {
    
    /// Raw string representing raw org mode files
    var orgRawString: String = ""
    
    override func contents(forType typeName: String) throws -> Any {
        return orgRawString.data(using: .utf8)!
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        let content = contents as! Data
        self.orgRawString = String(data: content, encoding: .utf8)!
    }
    
}
