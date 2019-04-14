//
//  UntypedResult.swift
//  Kekka
//
//  Created by Vijaya Prakash Kandel on 21.10.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation

/// Useful when the client wants to know if concrete type of the
/// failure cases and decide to perform some action based on the
/// type of the failure value.
///
/// Unlike Result<T> which considers all failure case to have Error
/// conforming types whereby easing the concrete type information.
/// ResultTyped<T,U> preserves the type of both branch.
/// When U conforms to Error type there is a handy conversion function
/// to coerce to Result<T> type.
public enum ResultTyped<SuccessValue, FailureValue> {
    case success(SuccessValue)
    case failure(FailureValue)
}


public extension ResultTyped where FailureValue: Error {

    public var untyped: KResult<SuccessValue> {
        switch self {
        case let .success(v):
            return .success(v)
        case let .failure(v):
            return .failure(v)
        }
    }

}


extension ResultTyped: Equatable where FailureValue: Error, SuccessValue: Equatable {

    public static func == (lhs: ResultTyped<SuccessValue, FailureValue>, rhs: ResultTyped<SuccessValue, FailureValue>) -> Bool {
        return lhs.untyped == rhs.untyped
    }

}

