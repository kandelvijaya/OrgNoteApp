import UIKit
import EnablePlaygroundShare
import Kekka


struct SubModel: Hashable {
    let name: String
    let age: Int
}

struct Model {

    let name: String
    let meta: String?
    let subitems: [SubModel]

}

extension Model: Diffable {

    func isContainerEqual(to anotherParent: Model) -> Bool {
        return self.name == anotherParent.name &&
            self.meta == anotherParent.meta
    }

    func internalDiff(with anotherParent: Model) -> [DiffResult<SubModel>] {
        let idiff = exceptUnchanged(diff(self.subitems, anotherParent.subitems))
        return idiff
    }
}

extension SubModel: Diffable { }

let puppy = SubModel(name: "puppy", age: 1)
let puss = SubModel(name: "puss", age: 0)
let kale = SubModel(name: "kale", age: 2)

let ownerBj = Model(name: "Bj", meta: "about to have", subitems: [puppy, puss])


let ownerBjCopyWithAll = Model(name: ownerBj.name, meta: ownerBj.meta, subitems: ownerBj.subitems + [kale])


extension DiffResult: CustomPlaygroundDisplayConvertible {

    public var playgroundDescription: Any {
        switch self {
        case let .deleted(item: item, fromIndex: index):
            return " ⛔️ Deleted \(item) from index \(index) "
        case let .inserted(item: item, atIndex: index):
            return " ⤵️ Inserted \(item) at index \(index) "
        case let .moved(item: item, fromIndex: fromIndex, toIndex: toIndex):
            return " 🏃 Moved \(item) from index \(fromIndex) to index \(toIndex) "
        case let .internalEdit(edits, atIndex: atIndex, forItem: parentItem):
            let alllist = edits.map({ $0.playgroundDescription as! String }).joined(separator: "\n")
            let title = "Internal Edits atIndex \(atIndex) for parent item \(parentItem) \n"
            return title + alllist
        default:
            return "unchanged"
        }
    }


}



diff([ownerBj], [ownerBjCopyWithAll])
