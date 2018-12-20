//
//  OrgFileOperation.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 18.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import Kekka

extension Array where Element == Outline {


    /// Adds a new `Outline` as child of given parent `Outline`
    ///
    /// - Parameters:
    ///   - item: new Outline
    ///   - childOf: Parent Outline. This is for sanity
    /// - Returns: New OrgFile
    func add(_ item: Outline, childOf: Outline) -> OrgFile {
        
    }

    /// appends at root
    func addAtRoot(_ item: Outline) -> OrgFile {
        return self + [item]
    }

    func deleteRoot(_ item: Outline) -> OrgFile {
        return []
    }

    func delete(_ item: Outline, childOf: Outline) -> OrgFile {
        return []
    }

    func update(old item: Outline, new newItem: Outline) -> OrgFile {
        return []
    }

}
