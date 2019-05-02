//
//  OrgRawEditorDriver.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 21.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import UIKit

struct OrgRawEditorDriver {

    var controller: FullScreenOrgRawEditorController {
        return FullScreenOrgRawEditorController.create(input: self.orgFileInput, onDismiss: self.onDismiss)
    }

    private let orgFileInput: OrgFile
    private let onDone: (OrgFile?) -> Void

    init(with input: OrgFile, onDone: @escaping (OrgFile?) -> Void) {
        self.orgFileInput = input
        self.onDone = onDone
    }

    private func onDismiss(newOrgFile: OrgFile?) {
        self.onDone(newOrgFile)
    }

}
