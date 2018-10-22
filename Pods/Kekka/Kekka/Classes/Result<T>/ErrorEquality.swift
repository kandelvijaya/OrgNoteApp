//
//  ErrorEquality.swift
//  Kekka
//
//  Created by Vijaya Prakash Kandel on 21.10.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation

/**
 Adding Equality to Error type.

 extension Error: Equatable {} is not possible as extensions
 cannot have inheritance clause.

 This is a equality on any 2 instance of Error.
 */
public func areEqual(_ lhs: Error, _ rhs: Error) -> Bool {
    return lhs.reflectedString == rhs.reflectedString
}


public extension Error {

    var reflectedString: String {
        return String(reflecting: self)
    }

    // Same typed Equality
    public func isEqual(to: Self) -> Bool {
        return self.reflectedString == to.reflectedString
    }

}


public extension NSError {
    // prevents scenario where one would cast swift Error to NSError
    // whereby losing the associatedvalue in Obj-C realm.
    // (IntError.unknown as NSError("some")).(IntError.unknown as NSError)
    public func isEqual(to: NSError) -> Bool {
        let lhs = self as Error
        let rhs = to as Error
        return self.isEqual(to) && lhs.reflectedString == rhs.reflectedString
    }
}
