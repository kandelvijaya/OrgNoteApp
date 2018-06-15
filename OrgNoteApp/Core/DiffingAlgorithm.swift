//
//  DiffingAlgo.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 13.05.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation

public func diff<T>(_ initial: [T],_ new: [T]) -> [DiffResult<T>] where T: Hashable {
    // refine simpleDiff
    let actions = simpleDiff(initial, new)

    let refined = actions.map { i -> DiffResult<T> in
        guard let sameValuedContra = actions.find ({ needle in
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

extension Array {
    func find(_ predicate: (Element) -> Bool) -> Element? {
        for index in self where predicate(index) == true {
            return index
        }
        return nil
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}


func simpleDiff<T>(_ initial: [T],_ new: [T]) -> [DiffResult<T>] where T: Hashable {
    var accumulator = [DiffResult<T>]()
    for (index, (oldi, newi)) in zip(initial, new).enumerated() {
        if oldi != newi {
            accumulator.append(.deleted(item: oldi, fromIndex: index))
            accumulator.append(.inserted(item: newi, atIndex: index))
        } else {
            accumulator.append(.unchanged(item: newi, atIndex: index))
        }
    }

    let minimum = min(initial.count, new.count)
    let differenceCount = initial.count - new.count
    if differenceCount > 0 {
        for (index, value) in initial[new.count..<initial.count].enumerated() {
            accumulator.append(.deleted(item: value, fromIndex: index + minimum))
        }
    } else if differenceCount < 0 {
        for (index, value) in new[initial.count..<new.count].enumerated() {
            accumulator.append(.inserted(item: value, atIndex: index + minimum))
        }
    }

    return accumulator
}


public enum DiffResult<T: Hashable>: Hashable {
    case deleted(item: T, fromIndex: Int)
    case inserted(item: T, atIndex: Int)
    case unchanged(item: T, atIndex: Int)
    case moved(item: T, fromIndex: Int, toIndex: Int)
}

public func exceptUnchanged<T>(_ input: [DiffResult<T>]) -> [DiffResult<T>] where T: Hashable{
    return input.filter {
        if case  .unchanged(_) = $0 { return false }
        return true
    }
}

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
