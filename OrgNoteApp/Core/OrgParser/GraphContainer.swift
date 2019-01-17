//
//  Graph.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 17.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation

typealias GraphHash =  Int

protocol DepthReportable: Hashable {
    var depth: Int { get }
}

protocol Directable: Hashable {
    var next: [GraphHash] { get set }
    var prev: GraphHash? { get set }
}


struct GraphContainer<T: DepthReportable> {

    struct Node<T: DepthReportable>: Directable, DepthReportable {

        let item: T
        var next: [GraphHash]
        var prev: GraphHash?

        var hashValue: Int {
            return self.item.hashValue
        }

        var depth: Int {
            return item.depth
        }

        func children(on container: GraphContainer<T>) -> [GraphContainer<T>.Node<T>] {
            return self.next.compactMap { container.storage[$0] }
        }

        func parent(on container: GraphContainer<T>) -> GraphContainer<T>.Node<T>? {
            return self.prev.flatMap { container.storage[$0] }
        }

        func subItems(on container: GraphContainer<T>) -> [GraphContainer<T>.Node<T>] {
            let iHash = item.hashValue
            guard let node = container.storage[iHash]  else { return [] }
            return node.next.compactMap { container.storage[$0] }
        }

    }

    private var storage: [GraphHash: Node<T>]
    private var rootNode: GraphHash
    private var lastAddedItemPointer: GraphHash

    var root: Node<T> {
        return self.storage[self.rootNode]!
    }

    var last: Node<T> {
        return self.storage[self.lastAddedItemPointer]!
    }

    init(with rootItem: T) {
        self.storage = [:]
        let root = Node(item: rootItem, next: [], prev: nil)
        self.rootNode = root.hashValue
        self.lastAddedItemPointer = root.hashValue

        self.storage[root.hashValue] = root
    }

    mutating func add(_ item: T) {
        let item = Node(item: item, next: [], prev: nil)
        // add from last Item perspective
        guard let suitableParent = findSuitableFirstParent(for: item, lookingUpwards: last) else {
            assertionFailure("Lower level that root found. Unsupported operation. Desing the first item such that this never happens")
            return
        }

        var parentCopy = suitableParent
        var itemCopy = item
        let pHash = parentCopy.hashValue
        let iHash = item.hashValue

        parentCopy.next.append(iHash)
        itemCopy.prev = pHash
        lastAddedItemPointer = iHash

        self.storage[pHash] = parentCopy
        self.storage[iHash] = itemCopy
    }

    private func findSuitableFirstParent(for child: Node<T>, lookingUpwards lookFrom: Node<T>) -> Node<T>? {
        if child.depth > lookFrom.depth {
            return lookFrom
        } else if child.depth == lookFrom.depth {
            guard let prevHash = lookFrom.prev, let prev = storage[prevHash] else {
                return nil // this is a root. No prev found
            }
            return prev
        } else {
            guard let prevHash = lookFrom.prev, let prev = storage[prevHash] else {
                return nil // this is the root. No prev found
            }
            return findSuitableFirstParent(for: child, lookingUpwards: prev)
        }
    }

}
