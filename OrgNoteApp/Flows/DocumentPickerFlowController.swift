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
        let orgFile = FileItem.File(url: firstURL, name: firstURL.path, ext: firstURL.pathExtension)
        let controller = OrgViewEditCoordinatingController.created(with: orgFile, onExit: { [weak self] in
            // write back maybe
            self?.dismiss(animated: true, completion: nil)
        })
        // dismiss any other modals and present the new one
        self.dismiss(animated: true, completion: nil)
        show(wrappedInNav(controller), sender: self)
    }
    
    private func wrappedInNav(_ controller: UIViewController) -> UIViewController {
        let navController = UINavigationController(rootViewController: controller)
        return navController
    }
    
}
