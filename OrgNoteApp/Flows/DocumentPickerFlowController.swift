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
    
    private lazy var picker: UIDocumentPickerViewController = {
        let item = UIDocumentPickerViewController(documentTypes: [kOrgFileType], in: .import)
        item.delegate = self
        item.allowsMultipleSelection = false
        return item
    }()
    
    private func embed(_ picker: UIDocumentPickerViewController) {
        self.addChildViewController(picker)
        view.addSubview(picker.view)
        picker.view.frame = view.bounds
        picker.didMove(toParentViewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if self.presentedViewController == nil {
            present(picker, animated: true, completion: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
}

extension DocumentPickerFlowController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.dismiss(animated: true, completion: nil)
        guard let firstURL = urls.first else {
            assertionFailure("When document is picked there should be a url associated to it")
            return
        }
        
        let orgFile = FileItem.File(url: firstURL, name: firstURL.path, ext: firstURL.pathExtension)
        
        let controller = OrgViewEditCoordinatingController.created(with: orgFile, onExit: { [weak self] in
//            self?.dismiss(animated: true, completion: nil)
        })
        self.dismiss(animated: true, completion: nil)
        show(controller, sender: self)
    }
    
}
