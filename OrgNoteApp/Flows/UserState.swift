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

    private var _backingInSyncedSelectedRepo: UserSelectedRepository?

    var userSelectedRepo: UserSelectedRepository? {
        set {
            if let nv = newValue {
                storage.save(item: nv, for: userSelectedRepoKey)
            }
        }

        get {
            let repo: UserSelectedRepository? = storage.retrieve(for: userSelectedRepoKey)
            if let r = repo {
                let properRemote = oauth2Client.repoUrlRepacingNewAccessToken(r.remoteURL)
                let properSelectedRepo = UserSelectedRepository(model: r.model, remoteURL: properRemote, clonedURL: r.clonedURL)
                return properSelectedRepo
            } else {
                return nil
            }
        }
    }

    var userSelectedFileInRepo: FileItem.File? {
        set {
            if let nv = newValue {
                storage.save(item: nv, for: userSelectedFileKey)
            }
        }

        get {
            let ret: FileItem.File? = storage.retrieve(for: userSelectedFileKey)
            return ret
        }
    }

    init(with oauth2Client: BitbucketOauth2 = .shared, storage: StorageProtocol = DefaultsStorage()) {
        self.oauth2Client = oauth2Client
        self.storage = storage
    }

}
