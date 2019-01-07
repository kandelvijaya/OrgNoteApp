//
//  DefaultsStorage.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 07.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation

protocol StorageProtocol {
    func save<V: Codable>(item: V, for key: String)
    func retrieve<V: Codable>(for key: String) -> V?
}

struct DefaultsStorage: StorageProtocol {

    private let backingStorage: UserDefaults

    init(with backingStorage: UserDefaults = UserDefaults.standard) {
        self.backingStorage = backingStorage
    }

    func save<V>(item: V, for key: String) where V : Codable {
        if let plListValue = try? PropertyListEncoder().encode(item) {
            backingStorage.set(plListValue, forKey: key)
        }
    }

    func retrieve<V>(for key: String) -> V? where V : Codable {
        if let data = backingStorage.object(forKey: key) as? Data {
            let value = try? PropertyListDecoder().decode(V.self, from: data)
            return value
        } else {
            return nil
        }


    }

}
