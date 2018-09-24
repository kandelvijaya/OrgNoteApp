//
//  InternalDiff.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 25.09.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation

func internalDiff<T: Diffable>(from diffOperations: [Operation<T>.Simple]) -> [(offset: Int, operations: [Operation<T.InternalItemType>.Simple])] {
    var accumulator = [(offset: Int, operations: [Operation<T.InternalItemType>.Simple])]()
    for operation in diffOperations {
        switch operation {
        case let .update(oldContainer, newContainer, atIndex):
            let oldChildItems = oldContainer.children
            let newChildItems = newContainer.children
            let internalDiff = orderedOperation(from: diff(oldChildItems, newChildItems))
            let output = (atIndex, internalDiff)
            accumulator.append(output)
        default:
            break
        }
    }
    return accumulator
}
