//
//  Promise.swift
//  Kekka
//
//  Created by Vijaya Prakash Kandel on 08.01.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation

/// Typealiased for users who are familiar to PromiseKit
/// and like the terminology of Promise.
public typealias KPromise<T> = Future<T>

public typealias KFuture<T> = Future<T>


/// A Functional type that encapsulates nested blocks
/// and their associated async task thereby providing a nice
/// synchronous and flow oriented programming model.
/// - note: This type doesnot explicitly handle error internally.
///         To handle error, prefer to use `Future<Result<T>>` and use
///         result types `bind`/`flatmap` intenally
public struct Future<T> {

    /// This is the actual completion block you would otherwise supply
    /// to a aysnc task.
    public typealias Completion = (T) -> Void

    /// This is the async task that we are abstracting over
    private var aTask: ((Completion?) -> Void)? = nil

    /// When creating a promise, you should call the only argument i.e. Completion before exiting.
    /// Provide the eventual value to the `Completion` block to mark this task is done.
    public init(_ task: @escaping ((Completion?) -> Void)) {
        self.aTask = task
    }

    /// Constructor for creating promise out of normal values. Also called lifting values.
    public init(_ value: T) {
        self.aTask = { aCompletion in
            aCompletion?(value)
        }
    }

    /// `then` is equivalent to `fmap`/`map`. It makes Promises Functorial.
    /// This deals with synchronous side of the world.
    /// - note: If you want to create a Prmose inside of then (you want to do async
    ///         task with eventual result), you are better off
    ///         using `bind`
    @discardableResult public func then<U>(_ transform: @escaping (T) -> U) -> Future<U> {
        return Future<U>{ upcomingCompletion in
            self.aTask?() { tk in
                let transformed = transform(tk)
                upcomingCompletion?(transformed)
            }
        }
    }

    /**
     `bind` is equivalent to `>>=`. It makes Promises Monadic.
     Similar to `flatMap` on Result<T> or Optional<T>, `bind` is implemented in terms of `then` and `join`.
     - note: If you want to perfrom synchronous task with the eventual value then prefer `then`

     - example:-
     ```
     Network(url).get().then { data -> ZResult<String> in
         print("Step 1")
         return data.bind(dataToString)
     }.then { str -> () in
         print("printing step 2")
         print(str.bind(takeFirstLine))
     }.bind { _ -> Promise<ZResult<Data>> in
         print("Step 3: Another task")
         return Network(url2).get()
     }.then { result -> () in
         print("Step 4 printing")
         print(result.bind(dataToString).bind(takeFirst20Chars))
     }.execute()
     ```
     */
    public func bind<U>(_ transform: @escaping (T) -> Future<U>) -> Future<U> {
        let transformed = then(transform)
        return Future.join(transformed)
    }

    static public func join<A>(_ input: Future<Future<A>>) -> Future<A> {
        return Future<A>{ aCompletion in
            input.then { innerPromise in
                innerPromise.then { innerValue in
                    aCompletion?(innerValue)
                    }.execute()
                }.execute()
        }
    }

    /// Call this method on any Promise type to execute and fulfill the promise.
    /// This is important because the design of Promises is to not evaluate immediately
    /// but create a expression that can be executed/ passed or stored. The expression
    /// can be internally be optimized or lazily evaluated.
    public func execute() {
        aTask?(nil)
    }

}
