//
//  BitbucketRepository.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 06.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation

struct BitbucketRepository: Codable, Hashable {
    let next: URL
    let page: Int
    let pagelen: Int
    let size: Int
    let values: [Value]

    struct Value: Codable, Hashable {
        let full_name: String
        let description: String
        let language: String
        let type: String
        let links: Link
    }

    struct Link: Codable, Hashable {
        let clone: [Clone]
    }

    struct Clone: Codable, Hashable {
        let name: String
        let href: URL
    }
}
