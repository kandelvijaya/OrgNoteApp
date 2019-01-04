//
//  DefaultCache.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 04.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation

struct BitbucketCache {

    private let storage: UserDefaults
    private let key: String

    init(storage: UserDefaults = .standard, clientSecretKey: String = "clientSecretKey") {
        self.storage = storage
        self.key = clientSecretKey
    }

    // IF not found then user has not logged in / authorized bitbucket
    var clientSecret: String? {
        return storage.string(forKey: key)
    }

    func store(clientSecret: String) {
        storage.set(clientSecret, forKey: key)
    }

}
