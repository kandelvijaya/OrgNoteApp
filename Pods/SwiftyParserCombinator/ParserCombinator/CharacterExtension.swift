//
//  Copyright © 2018 Vijaya Prakash Kandel. All rights reserved.
//

import Foundation

public extension Character {
    
    private var charSet: CharacterSet {
        return CharacterSet(charactersIn: String(self))
    }
    
    public var isAlphanumeric: Bool {
        return !charSet.intersection(CharacterSet.alphanumerics).isEmpty
    }
    
    public var isDigit: Bool {
        return !charSet.intersection(CharacterSet.decimalDigits).isEmpty
    }
    
}
