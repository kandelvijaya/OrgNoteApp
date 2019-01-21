//
//  OrgFileInteractable.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 21.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation

protocol OrgFileInteractable {
    func flattenedSectionsRevelaingAllExpandedContainers() -> [[Outline]]
    func replace(old: Outline, with new: Outline, childOf parent: Outline?) -> OrgFile
    func immediateParent(ofFirst firstMatching: Outline) -> Outline?
    func add(_ item: Outline, childOf: Outline) -> OrgFile
    func addAtRoot(_ item: Outline) -> OrgFile
    func deleteRoot(_ item: Outline) -> OrgFile
    func delete(_ item: Outline, childOf: Outline) -> OrgFile
    func update(old item: Outline, new newItem: Outline, childOf parent: Outline?) -> OrgFile
}
