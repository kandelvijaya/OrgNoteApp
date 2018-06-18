//
//  Diff.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 18.06.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation

/// Representation of diffing two sets of models.
public enum DiffResult<T: Diffable>: Hashable {
    case deleted(item: T, fromIndex: Int)
    case inserted(item: T, atIndex: Int)
    case unchanged(item: T, atIndex: Int)
    case moved(item: T, fromIndex: Int, toIndex: Int)
    case internalEdit(_ edits: [DiffResult<T.InternalItemType>], atIndex: Int, forItem: T)
}


public func diff<C: Collection>(_ old: C, _ new: C) -> [DiffResult<C.Element>] {
    let oldItems = old.enumerated().map { ($0.offset, $0.element) }
    let newItems = new.enumerated().map { ($0.offset, $0.element) }
    let simpleDiff = _diffWithoutMove(oldItems, newItems)
    let diffWithMove = _detectMove(in: simpleDiff)
    let diffWithoutUnchanged = exceptUnchanged(diffWithMove)
    return diffWithoutUnchanged
}

/// Time complexity O(n) for single level list of diffables.
///
/// time complexity really depends on how many nested levels of diffable items are present.
///
/// best case is O(n)
/// worst case is O(n * m) where m is average length of items from the second level.
/// If you have 3rd level of nesting then this diffing algorithm has a very very bad performance hit.
/// O(n * m * p) where p is the avergae items lenght on 3rd level
///
/// Space complexity : ArraySlice should not be copied when calling into the function
///                    accumulator has to adjust on every single mutation.
///                    can we determine or estimate the size of the diff result.
func _diffWithoutMove<T: Diffable, C: Collection>(_ old: C, _ new: C) -> [DiffResult<T>]
    where C.Element == (Int, T) {

        var accumulator = [DiffResult<T>]()
        let newHead = new.first
        let oldHead = old.first
        let newRest = new.dropFirst()
        let oldRest = old.dropFirst()

        switch (oldHead, newHead) {
        case let (o?, n?):
            if o.1 == n.1 {
                accumulator.append(DiffResult.unchanged(item: o.1, atIndex: o.0))
            } else if o.1.isContainerEqual(to: n.1) {
                let internalEdits = o.1.internalDiff(with: n.1)
                let edits = DiffResult.internalEdit(internalEdits, atIndex: o.0, forItem: o.1)
                accumulator.append(edits)
            } else {
                accumulator.append(DiffResult.deleted(item: o.1, fromIndex: o.0))
                accumulator.append(DiffResult.inserted(item: n.1, atIndex: n.0))
            }
        case let (o?, nil):
            accumulator.append(DiffResult.deleted(item: o.1, fromIndex: o.0))
        case let (nil, n?):
            accumulator.append(DiffResult.inserted(item: n.1, atIndex: n.0))
        default:
            return accumulator
        }

        return accumulator + _diffWithoutMove(oldRest, newRest)
}


public func exceptUnchanged<T>(_ input: [DiffResult<T>]) -> [DiffResult<T>] where T: Diffable {
    return input.filter {
        if case  .unchanged(_) = $0 { return false }
        return true
    }
}

/// find moves from a given list of simple diff
/// [1,2,3]
/// [2,3,1]
/// ==> 2 moved to 0
/// ==> 3 moved to 1
/// ==> 1 moved to 2
/// This has quadratic complexity
/// FIXME: try to get the complexity down to O(n.log.n)
///
/// Complexity: O(n^2)
fileprivate func _detectMove<T>(in diffResult: [DiffResult<T>]) -> [DiffResult<T>] {
    let refined = diffResult.map { i -> DiffResult<T> in

        guard let sameValuedContra = diffResult.first(where: { needle in
            switch (i, needle) {
            case let (.deleted(item: v, _), .inserted(item: v2,_ )) where v == v2:
                return true
            case let (.inserted(item: v, _), .deleted(item: v2,_ )) where v == v2:
                return true
            default:
                return false
            }
        }) else {
            return i
        }

        switch (i, sameValuedContra) {
        case let (.deleted(item: v, fromIndex: v1i), .inserted(item: v2, atIndex: v2i)) where v == v2:
            return .moved(item:v, fromIndex: v1i, toIndex: v2i)
        case let (.inserted(item: v, atIndex: v1i), .deleted(item: v2, fromIndex: v2i)) where v == v2:
            return .moved(item: v, fromIndex: v2i, toIndex: v1i)
        default:
            return i
        }
    }

    return refined.unique()
}


extension Sequence where Iterator.Element: Hashable {

    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }

}


extension Array {

    func find(_ predicate: (Element) -> Bool) -> Element? {
        for index in self where predicate(index) == true {
            return index
        }
        return nil
    }

}
