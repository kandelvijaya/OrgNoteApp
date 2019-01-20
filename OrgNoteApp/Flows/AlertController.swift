//
//  AlertController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 18.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import UIKit
import StatusAlert

class AlertController {

    static func alertNegative(_ message: String) {
        let statusAlert = StatusAlert()
        statusAlert.image = UIImage(named: "cross")
        statusAlert.title = "Something went wrong!"
        statusAlert.message = "\(message)"
        statusAlert.canBePickedOrDismissed = true
        statusAlert.appearance.backgroundColor = UIColor.red
        statusAlert.showInKeyWindow()
    }

    static func alertPositive(_ message: String) {
        let statusAlert = StatusAlert()
        statusAlert.image = UIImage(named: "tick")
        statusAlert.title = "Yup That worked"
        statusAlert.message = "\(message)"
        statusAlert.canBePickedOrDismissed = true
        statusAlert.showInKeyWindow()
    }

}
