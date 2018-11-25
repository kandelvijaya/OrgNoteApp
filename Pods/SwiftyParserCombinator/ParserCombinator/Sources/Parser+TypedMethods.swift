import Foundation

// Instance (typed) methods for Parser
// Note: This are just aliased to free functions.
// For source of truth please refer to
// Parser+Combinator.swift

extension Parser {
    
    /// functor
    public func map<U>(_ transform: @escaping (Output) -> U) -> Parser<U> {
        return self |>> transform
    }
    
    /// applicative
    public func applic<U>(_ wrapped: Parser<((Output) -> U)>) -> Parser<U> {
        return wrapped <*> self
    }
    
    /// monadic
    public func flatMap<U>(_ transform: @escaping ((Output) -> Parser<U>)) -> Parser<U> {
        return self |>>= transform
    }
    
}
