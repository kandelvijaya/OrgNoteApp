//
//  Result.swift
//  Kekka
//
//  Created by Vijaya Prakash Kandel on 08.01.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation

/// Typealiased so that users of libraries such as PromiseKit, ResultKit, etc
/// as either direct or indirect dependencies can unambigiously refer to this
/// Monadic Typed Resutl.
public typealias KResult<T> = Result<T>

/**
 Encapsulates contextual computation (computations that can fail or succeed, i.e async task, divsion by 0, etc).
 This is equivalent to the `Optional<T>` standard type but with added failure context. The client might
 want to notify user what went wrong or decide to do something else depending on various error.
 */
public enum Result<T> {

    case success(value: T)
    case failure(error: Error)

}


public extension Result {

    /**
     Takes a contextual (might fail) transform `T -> Result<U>` where T is the internal
     item type when current Result represents success.
     - parameter transform: `T -> Result<U>`
     - returns: `Result<U>`. If current Result has error case, then we return as is.
     */
    public func flatMap<U>(_ transform: (T) -> Result<U>) -> Result<U> {
        let transformed = map(transform)
        return flatten(transformed)
    }

    /**
     Takes a normal transform `T -> U` where T is the internal item type when current Result
     represent success.
     - parameter transform: `T -> U`
     - returns: `Result<U>` with the transformed value if current Result represents success.
     Else, it returns the failure as is.
     */
    public func map<U>(_ transform: (T) -> U) -> Result<U> {
        switch self {
        case let .success(v):
            return .success(value: transform(v))
        case let .failure(e):
            return .failure(error: e)
        }
    }

    private func flatten<A>(_ input: Result<Result<A>>) -> Result<A> {
        switch input {
        case let .success(v):
            return v
        case let .failure(e):
            return .failure(error: e)
        }
    }

}

public extension Result {

    var value: T? {
        if case .success(value: let value) = self {
            return value
        }
        return nil
    }

    var error: Error? {
        if case .failure(error: let error) = self {
            return error
        }
        return nil
    }

}

public extension Result {

    var succeeded: Bool {
        switch self {
            case .success: return true
            case .failure: return false
        }
    }

    var failed: Bool {
        switch self {
            case .success: return false
            case .failure: return true
        }
    }

}

public extension Result {

    /// In case error has to be transformed
    public func mapError(_ transform: (Error) -> Error) -> Result<T> {
        switch self {
        case let .success(v):
            return .success(value: v)
        case let .failure(e):
            return .failure(error: transform(e))
        }
    }

}

/**
 Extending Error type for easy creation of KResult<T> failed case.
 */
public extension Error {

    public func result<T>() -> Result<T> {
        return Result<T>.failure(error: self)
    }

}

// MARK:- Equality on Result type

extension Result: Equatable where T: Equatable {

    public static func == (lhs: Result<T>, rhs: Result<T>) -> Bool {
        switch (lhs, rhs) {
        case let (.success(value: v1), .success(value: v2)):
            return v1 == v2
        case let (.failure(error: e1), .failure(error: e2)):
            return areEqual(e1, e2)
        default:
            return false
        }
    }

}

