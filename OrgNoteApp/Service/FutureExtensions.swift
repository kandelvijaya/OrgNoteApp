//
//  FutureExtensions.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 22.10.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import Kekka

/// FIXME: This is a pure hack. Nasty one.
fileprivate class _LocalCapture {
    static var value: Any? = nil
}

public extension Future {

    /// Provides a helper accessor to get the result immediately
    /// NOTE:- call this only when you are sure this is a synchronous task
    public var resultingValueIfSynchornous: T? {
        guard Thread.isMainThread else {
            return nil
        }

        self.then { res in
            if Thread.isMainThread {
                _LocalCapture.value = res
            } else {
                NSLog("%@ doesnot work when running asynchronously or other thread than main.", #function)
            }
        }.execute()

        let lastExecutedResult = _LocalCapture.value as? T
        defer {
            _LocalCapture.value = nil
        }
        return lastExecutedResult
    }

}
