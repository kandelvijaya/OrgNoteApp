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

final class DocumentPickerFlowController: UIViewController {
    
    @IBAction func openDocument(_ sender: UIButton) {
        let picker = UIDocumentPickerViewController(documentTypes: [kOrgFileType], in: .import)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true, completion: nil)
    }
    
}

extension DocumentPickerFlowController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let firstURL = urls.first else {
            assertionFailure("When document is picked there should be a url associated to it")
            return
        }
        
    }
    
}
