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
    private var onSave: ((OrgFile?) -> Void)!
    private var onDismiss: ClosedBlock!

    static func create(input orgFile: OrgFile, onSave: @escaping (OrgFile?) -> Void, onDismiss: @escaping ClosedBlock) -> OrgRawEditorController {
        let vc = UIStoryboard(name: String(describing: OrgRawEditorController.self), bundle: Bundle(for: OrgRawEditorController.self)).instantiateViewController(withIdentifier: String(describing: OrgRawEditorController.self)) as! OrgRawEditorController
        vc.orgFile = orgFile
        vc.onSave = onSave
        vc.onDismiss = onDismiss
        return vc
    }

}
