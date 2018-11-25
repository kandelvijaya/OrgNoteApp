//
//  Copyright © 2018 Vijaya Prakash Kandel. All rights reserved.
//

import Foundation

public struct ParserError {
    public typealias Label = String
    let label: Parser<Any>.Label
    let error: String
    let position: ParserErrorPosition
}

public func error(_ label: Parser<Any>.Label, _ errorDescription: String, _ state: InputState) -> ParserError {
    return ParserError(label: label, error: errorDescription, position: state.parserPosition())
}

public func error(_ label: Parser<Any>.Label, _ errorDescription: String, _ position: ParserErrorPosition) -> ParserError {
    return ParserError(label: label, error: errorDescription, position: position)
}


public func show<T>(_ result: ParserResult<T>) -> ParserResult<T> {
    switch result {
    case let .success(v):
        print(v)
    case let .failure(e):
        let lineInfoWithLabel = "Line: \(e.position.row + 1), Col: \(e.position.col) Error parsing \(e.label)"
        let errorDescription = "\(e.error)"
        let impactedLine = e.position.currentLine
        let whiteSpace = Array<Character>(repeating: Character(" "), count: e.position.col - 1)
        let caret = "^____"
        let impact = String(whiteSpace) + caret + errorDescription
        print(lineInfoWithLabel)
        print(impactedLine)
        print(impact)
    }
    
    return result
}

