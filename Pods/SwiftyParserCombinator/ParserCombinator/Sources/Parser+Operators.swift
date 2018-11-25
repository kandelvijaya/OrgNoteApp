import Foundation

/// Operators

precedencegroup ApplicationPrecedenceGroup {
    associativity: left
    higherThan: AssignmentPrecedence
}


infix operator |>: ApplicationPrecedenceGroup
public func |> <T,U>(_ value: T, _ transfrom: (T) -> U) -> U {
    return transfrom(value)
}


infix operator |?>: ApplicationPrecedenceGroup
public func |?> <T,U>(_ value: T?, _ transfrom: (T) -> U) -> U? {
    return value.map(transfrom)
}


infix operator <|>: ApplicationPrecedenceGroup
public func <|> <T>(_ lhs: Parser<T>, _ rhs: Parser<T>) -> Parser<T> {
    return lhs.orElse(rhs)
}


/*
 Would be nice if we could use .>>., .>> and >>.
 However, swift compiler warns for the last instance: >>.
 */

infix operator ->>-: ApplicationPrecedenceGroup
public func ->>- <T,U>(_ lhs: Parser<T>, _ rhs: Parser<U>) -> Parser<(T,U)> {
    return lhs.andThen(rhs)
}


infix operator ->>: ApplicationPrecedenceGroup
public func ->> <T,U>(_ lhs: Parser<T>, _ rhs: Parser<U>) -> Parser<T> {
    return lhs.keepLeft(rhs)
}


infix operator >>-: ApplicationPrecedenceGroup
public func >>- <T,U>(_ lhs: Parser<T>, _ rhs: Parser<U>) -> Parser<U> {
    return lhs.keepRight(rhs)
}

