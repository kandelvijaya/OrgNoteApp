//
//  UserState.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 07.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation

struct UserSelectedRepository: Codable {
    let model: BitbucketRepository.Value
    let remoteURL: URL
    let clonedURL: URL
}


struct UserState {

    let oauth2Client: BitbucketOauth2
    private let storage: StorageProtocol
    private let userSelectedRepoKey = "userSelectedRepoKey"
    private let userSelectedFileKey = "userSelectedFileKey"

    var userSelectedRepo: UserSelectedRepository?
    var userSelectedFileInRepo: FileItem.File?

    init(with oauth2Client: BitbucketOauth2 = .shared, storage: StorageProtocol = DefaultsStorage()) {
        self.oauth2Client = oauth2Client
        self.storage = storage
    }

}
