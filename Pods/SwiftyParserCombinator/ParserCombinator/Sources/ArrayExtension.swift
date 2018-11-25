import Foundation

extension Array {
    
    /// Reduces the collection from left to right similar to reduce
    /// However, supplies the first argument as the initial result
    /// Useful, when either the Element doesnot have identity AKA is not a monoid.
    /// [1,2,3].foldl(by: +) rather than [1,2,3].reduce(0, +)
    ///
    /// - Parameter by: A function which will be supplied with result and next item
    /// - Returns: Accumulated result value OR Optional when the list is empty.
    public func foldl1(by: (Element, Element) -> Element) -> Element? {
        guard let first = self.first else {
            assertionFailure("foldl with empty list is programming error")
            return nil
        }
        let other = dropFirst()
        return other.reduce(first) { (result, item)in
            return by(result, item)
        }
    }
    
}
