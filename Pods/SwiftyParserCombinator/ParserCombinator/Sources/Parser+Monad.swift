import Foundation

// MARK:- Monadic Combinators. Most of the functions are free functions
// It is sometimes hard to comprehend free functions under composition with
// custom operator thereby associated instance method is provided.
// Refer to Parser+TypedMethpds.swift.
// Please note: typed methods are just a alias on the free function.


/// Map over the input Parser by supplied transform function.
/// This makes Parser Functor.
///
/// - Parameters:
///   - by: (T) -> U
///   - input: Parser<T>
/// - Returns: Parser<U>
public func map<T,U>(_ by: @escaping (T) -> U, to inParser: Parser<T>) -> Parser<U> {
    return Parser<U> { input in
        let firstRun = inParser |> run(input)
        switch firstRun {
        case let .success(v):
            let output = (by(v.0), v.1)
            return .success(output)
        case let .failure(e):
            return .failure(e)
        }
    } <?> inParser.label
}


/// Custom operator for Parser map
infix operator |>>: ApplicationPrecedenceGroup
public func |>> <T,U>(_ value: Parser<T>, _ transfrom: @escaping (T) -> U) -> Parser<U> {
    return map(transfrom, to: value)
}

// Custom operator for Parser map when the parser is optional.
infix operator |?>>: ApplicationPrecedenceGroup
public func |?>> <T,U>(_ value: Parser<T>?, _ transfrom: @escaping (T) -> U) -> Parser<U>? {
    return value.map { map(transfrom, to: $0) }
}



/// How do we compose 2 function of type
/// f1: A -> Parser<B> , f2: B -> Parser<C>
/// This makes Parser Monadic. This is equivalent
/// to bind or >>= in Haskell.
///
/// - Parameters:
///   - inputValue: Parser<T>
///   - by: (T) -> Parser<U>
/// - Returns: Parser<U>
public func flatMap<T, U>(_ inputValue: Parser<T>, _ by: @escaping (T) -> Parser<U>) -> Parser<U> {
    return map(by, to: inputValue) |> join
}


/// Custom Operator for monadic bind / flatMap
infix operator |>>=: ApplicationPrecedenceGroup
public func |>>= <T,U>(_ parser: Parser<T>, _ transform: @escaping ((T) -> Parser<U>)) -> Parser<U> {
    return flatMap(parser, transform)
}





/// Flattens a nested parsers into a single parser
/// Currently works on double layered input.
/// FIXME: Add support for n layers input with generics
///
/// - Parameter parser: Parser<Parser<T>>
/// - Returns: Parser<T>
public func join<T>(_ parser: Parser<Parser<T>>) -> Parser<T> {
    return Parser<T> { input in
        let outerRun = parser |> run(input)
        switch outerRun {
        case let .failure(e):
            return .failure(e)
        case let .success(value):
            let innerRun = value.0 |> run(value.1)
            return innerRun
        }
    }
}



/// Lifting function. Also known as return or pure in
/// functional programming languages
///
/// - Parameter output: T
/// - Returns: Parser<T> where output is prefilled
public func lift<T>(_ output: T) -> Parser<T> {
    return Parser<T> { input in
        let out = (output, input)
        return .success(out)
    }
}


/// Applicative apply. Applies the function stuck in wrapped parser to the
/// parser with concrete value. This makes Parser Applicative.
/// Monad are superior to applicative, however we will have this nice
/// apply in place.
/// This answers the question what if I have a normal parser Parser<T>
/// and another parser which has a function stuck inside Parser<(T -> U)>.
/// How can we compose them?
///
/// - Parameters:
///   - wrapped: Parser<(T->U)>
///   - parser: Parser<T>
/// - Returns: Parser<U>
public func applic<T,U>(_ wrapped: Parser<((T) -> U)>, to parser: Parser<T>) -> Parser<U> {
    return wrapped |>>= { function in
        return parser |>> function
    }
}

/// Custom operator for applicative apply.
infix operator <*>: ApplicationPrecedenceGroup
public func <*><T,U>(_ wrapped: Parser<((T) -> U)>, _ parser: Parser<T>) -> Parser<U> {
    return applic(wrapped, to: parser)
}

