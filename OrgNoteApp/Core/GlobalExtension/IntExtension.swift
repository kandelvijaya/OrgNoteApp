//
//  IntExtension.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 16.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation

extension Int {

    static func random(fittingSize: Int) -> Int {
        return Int.random(in: ClosedRange(uncheckedBounds: (lower: 0, upper: fittingSize)))
    }

}

