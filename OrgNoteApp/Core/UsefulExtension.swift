//
//  UsefulExtension.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 02.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import Kekka

func doTry<T>(_ tryBlock: () throws -> T) -> Result<T> {
    return doTry(tryBlock, elseBlock: nil)
}

func doTry<T>(_ tryBlock: () throws -> T, elseBlock: ((Error) -> Error)? ) -> Result<T> {
    do {
        let result = try tryBlock()
        return result |> Result.success
    } catch {
        let failure = elseBlock.map{ $0(error) } ?? error
        return failure |> Result.failure
    }
}
