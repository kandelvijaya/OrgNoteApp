//
//  Diffable.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 18.06.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation

public protocol Diffable: Hashable {

    /// euqality of parent's properties without regard to the underlying items.
    /// By default, this calls into the Equatable's `==` method.
    ///
    /// Customize this when you want to diff internal items independently
    /// to the outer parent. A analogy to look for is file diff.
    /// Rather than saying the file is deleted and inserted when a new line is added
    /// or a line is edited; we want to say the file is edited and the edits happened
    /// on the deeper level ([lines])
    func isContainerEqual(to anotherParent: Self) -> Bool

    /// Used to represent the internalItemType that represents another level.
    /// By default, this will be the same type as the conforming i.e. without customization.
    associatedtype InternalItemType: Diffable = Self

    /// if the parent's are same besides the internal/ underlying items
    /// then this method is invoked to find the edits for given model
    ///
    /// ```swift
    ///     struct Model {
    ///         let meta: [String]
    ///         let subItems: [String]
    ///     }
    ///     let models1 = [Model(meta: ["meta"], subItems: ["Dog", "Cat"])]
    ///     let models2 = [Model(meta: ["meta"], subItems: ["Dog", "Elephant"])]
    ///     diff(modesl, models2)
    /// ```
    /// In this case, models1 and models2 are same on container level.
    /// However they are different on subItems (underlying) level.
    /// We could naively say its `deletion of models1` and `insertion of models2`
    /// However it is much effecient to say
    /// `models1 is the same as models2 with these edits applied`
    /// - Cat is removed from index 1 of subItems
    /// - Elephant is inserted at index 1 of subItems
    func internalDiff(with anotherParent: Self) -> [DiffResult<InternalItemType>]

}


public extension Diffable {

    public func isContainerEqual(to anotherParent: Self) -> Bool {
        return self == anotherParent
    }

    public func internalDiff(with anotherParent: Self) -> [DiffResult<Self>] {
        return []
    }

}
