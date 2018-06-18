//
//  ListSectionDiffAlgorithm.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 15.06.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit

/// Diff to find changes in row/s for a given section.
/// When a section has a new cell then we want to know that
/// the row changed (by insertion) rather than the entire section
/// changed.
func diffSection<T: Hashable>(_ old: ListSectionDescriptor<T>, _ new: ListSectionDescriptor<T>) -> [DiffResult<ListCellDescriptor<T,UITableViewCell>>] {
    let oldSectionItems = old.items
    let newSectionItems = new.items
    let diffResult = diff(oldSectionItems, newSectionItems)
    return diffResult
}
