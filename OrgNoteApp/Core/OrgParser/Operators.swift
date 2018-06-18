//
//  Operators.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 13.05.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation

precedencegroup Application {
    higherThan : AssignmentPrecedence
    associativity : left
}

infix operator |> : Application
public func |> <T,U>(_ lhs: @autoclosure () -> T, rhs: @escaping (T) -> U) -> U {
    return rhs(lhs())
}
