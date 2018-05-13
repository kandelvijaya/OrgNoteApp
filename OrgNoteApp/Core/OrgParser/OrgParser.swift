//
//  OrgParser.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 13.05.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import ParserCombinator


typealias OrgFile = [Outline]


struct OutlineHeading: Hashable {

    let title: String
    let depth: Int

}


struct Outline: Hashable {

    let heading: OutlineHeading
    let content: [String]
    let subItems: [Outline]

    init(heading: OutlineHeading, content: [String], subItems: [Outline] = []) {
        self.heading = heading
        self.content = content
        self.subItems = subItems
    }

}

// [Outline] or [String] were not Hashable by default.
extension Array: Hashable where Element: Hashable {

    public var hashValue: Int {
        guard let first = self.first else {
            return "\(Element.self)".hashValue
        }
        return dropFirst().reduce(first.hashValue) {
            return $0 ^ $1.hashValue
        }
    }

}

struct OrgParser {

    static func parse(_ contents: String) -> OrgFile? {
        let parsed = orgParser() |> many |> run(contents)
        return parsed.value()?.0
    }

}




/*
 This could also be represented as
 enum Outline {
 case tree(heading: String, content: [String], subTrees: [Outline])
 }
 */

fileprivate let pstars = pchar("*") |> many1
fileprivate let anyCharacterBesidesNewLine = satisfy({ $0 != Character("\n") }, label: "Except New Line")
fileprivate let newLine = pchar("\n") |> many1

fileprivate func headingParser() -> Parser<OutlineHeading> {
    let p = (pstars ->> (pchar(" ") |> many1)) ->>- (anyCharacterBesidesNewLine |> many1) ->> newLine
    let pH = p |>> { OutlineHeading(title: String($1), depth: $0.count) }
    return pH <?> "Org Heading"
}

fileprivate func headingParser(depth: Int) -> Parser<OutlineHeading> {
    let depthStars = Array<Parser<Character>>(repeating: pchar("*"), count: depth) |> sequenceOutput
    let p = (depthStars ->> (pchar(" ") |> many1)) ->>- (anyCharacterBesidesNewLine |> many1) ->> newLine
    let pH = p |>> { OutlineHeading(title: String($1), depth: $0.count) }
    return pH <?> "Org Heading"
}

/// Run the parser Parser<U> unless the next stream is satisfied with Parser<T>
fileprivate func parseUntil<T,U>(_ next: Parser<T>) -> (Parser<U>) -> Parser<[U]> {
    return { useParser in
        return Parser<[U]> { input in

            var fedInput = input
            var accumulatorResult = [U]()
            while fedInput.currentLine != InputState.EOF, let _ = (next |> run(fedInput)).error() {
                if let thisValue = (useParser |> run(fedInput)).value() {
                    accumulatorResult.append(thisValue.0)
                    fedInput = thisValue.1
                } else {
                    // neither thisParser Matched nor the next
                    return [useParser] |> sequenceOutput |> run(fedInput)
                }
            }

            let out = (accumulatorResult, fedInput)
            return .success(out)
        }
    }
}


fileprivate func contentParser() -> Parser<[String]> {
    let anyContent = (anyCharacterBesidesNewLine |> many1) ->> newLine |>> {String($0)}
    let manyLines = anyContent |> parseUntil(headingParser())
    return manyLines <?> "Org Content"
}

fileprivate func outlineParser() -> Parser<Outline> {
    return headingParser() ->>- contentParser() |>> { Outline(heading: $0, content: $1) }
}

fileprivate func outlineParser(for level: Int) -> Parser<Outline> {
    return headingParser(depth: level) ->>- contentParser() |>> { Outline(heading: $0, content: $1) }
}


fileprivate func orgParser(start startLevel: Int = 1) -> Parser<Outline> {
    typealias Output = ParserResult<(Outline, Parser<Outline>.RemainingStream)>
    return Parser<Outline> { input in
        let thisLevel = outlineParser(for: startLevel) |> run(input)
        let mapped: Output = thisLevel.flatMap { v in
            let nextLevel = startLevel + 1
            let nextRun = orgParser(start: nextLevel) |> many |> run(v.1)

            let inner: Output = nextRun.map { subV in
                let output = Outline(heading: v.0.heading, content: v.0.content, subItems: subV.0)
                return (output, subV.1)
            }
            return inner
        }
        return mapped
    }
}


