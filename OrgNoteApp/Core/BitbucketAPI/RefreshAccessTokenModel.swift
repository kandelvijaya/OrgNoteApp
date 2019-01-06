//
//  RefeshAccessTokenModel.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 06.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation

struct RefreshAccessTokenModel: Codable {
    let type: String
    let error: ErrorObj

    struct ErrorObj: Codable {
        let message: String
    }
}
