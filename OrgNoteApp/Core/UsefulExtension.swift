//
//  UsefulExtension.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 02.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import Kekka

func doTry<T>(_ tryBlock: @autoclosure () throws -> T, elseBlock: ((Error) -> Error)? = nil ) -> Result<T> {
    do {
        let result = try tryBlock()
        return result |> Result.success
    } catch {
        let failure = elseBlock.map{ $0(error) } ?? error
        return failure |> Result.failure
    }
}
