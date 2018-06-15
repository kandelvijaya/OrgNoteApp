import UIKit
import EnablePlaygroundShare
import Kekka

protocol Diffable: Hashable {
    associatedtype Element: Hashable
    var itemsToDiff: [Element] { get }
}


extension Array: Diffable where Element: Hashable {

    var itemsToDiff: [Element] {
        return self
    }

}


struct SubModel: Hashable {
    let name: String
    let age: Int
}

struct Model: Diffable {
    let name: String
    let meta: String?
    let subitems: [SubModel]

    var itemsToDiff: [SubModel] {
        return subitems
    }
}


let puppy = SubModel(name: "puppy", age: 1)
let puss = SubModel(name: "puss", age: 0)
let kale = SubModel(name: "kale", age: 2)

let ownerBj = Model(name: "Bj", meta: "about to have", subitems: [puppy, puss])


let ownerBjCopyWithAll = Model(name: ownerBj.name, meta: ownerBj.meta, subitems: ownerBj.subitems + [kale])

let diffRaw = diff([ownerBj], [ownerBjCopyWithAll])
let diffResult = exceptUnchanged(diffRaw)
print(diffResult)

let diffC = exceptUnchanged(diffContainer(ownerBj, ownerBjCopyWithAll))
print(diffC)


let diffC2 = exceptUnchanged(diffContainer([ownerBj, ownerBj], [ownerBjCopyWithAll, ownerBj]))
print(diffC2)

extension DiffResult: CustomPlaygroundDisplayConvertible {

    public var playgroundDescription: Any {
        switch self {
        case let .deleted(item: item, fromIndex: index):
            return " ⛔️ Deleted \(item) from index \(index) "
        case let .inserted(item: item, atIndex: index):
            return " ⤵️ Inserted \(item) at index \(index) "
        case let .moved(item: item, fromIndex: fromIndex, toIndex: toIndex):
            return " 🏃 Moved \(item) from index \(fromIndex) to index \(toIndex) "
        default:
            return "unchanged"
        }
    }


}


func diffContainer<T: Diffable>(_ old: T, _ new: T) -> [DiffResult<T.Element>] {
    return diff(old.itemsToDiff, new.itemsToDiff)
}




// diff [section] to [section]
// for each do a section diff
// reduce / collect diff result
// apply the diff for each row

