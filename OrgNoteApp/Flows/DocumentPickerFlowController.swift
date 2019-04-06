//
//  DocumentPickerFlowController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 4/6/19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit

let kOrgFileType = ""

final class DocumentPickerFlowController: UIViewController {
    
    @IBAction func openDocument(_ sender: UIButton) {
        let picker = UIDocumentPickerViewController(documentTypes: [kOrgFileType], in: .import)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
}

extension DocumentPickerFlowController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print(urls)
    }
    
}
