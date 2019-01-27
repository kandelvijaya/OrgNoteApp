//
//  OrgRawEditorDriver.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 21.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import UIKit

struct OrgRawEditorDriver {

    var controller: OrgRawEditorController {
        return OrgRawEditorController.create(input: self.orgFileInput, onSave: self.onSave(_:), onDismiss: self.onDismiss)
    }

    private let orgFileInput: OrgFile
    private let onDone: (OrgFile?) -> Void

    private func onDismiss() {
        self.onDone(nil)
    }

    private func onSave(_ orgFile: OrgFile?) {
        self.onDone(orgFile)
    }

}
