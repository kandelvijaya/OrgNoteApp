//
//  OrgParser.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 13.05.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import SwiftyParserCombinator

struct OutlineTop: Hashable {

    struct Item: Hashable {
        let heading: OutlineHeading
        let content: [String]
    }

    let comments: [String]
    let outlines_flat: [Item]

}

struct OrgParser {

    private let pstars = pchar("*") |> many1
    private let anyCharacterBesidesNewLine = satisfy({ $0 != "\n" }, label: "Except New Line")
    private let newLine = pchar("\n")
    private let newLines = pchar("\n") |> many1

    static func parse(_ contents: String) -> OrgFile? {
        return OrgParser().parse_flattened(contents)
    }

}

extension OrgParser {

    func parse_flattened(_ contents: String) -> OrgFile? {
        let outlinesP = outlineParser() |> many
        let parser = comments() ->>- outlinesP |>> {
            OutlineTop(comments: $0.0, outlines_flat: $0.1)
        }
        let parsed = parser |> run(contents)
        guard let flattened = parsed.value()?.0 else {
            assertionFailure("can't parse org file")
            return nil
        }

        let subItems = flattened.outlines_flat

        var graphContainer = GraphContainer<OutlineTop.Item>(with: OutlineTop.Item.rootItem)
        subItems.forEach { item in
            graphContainer.add(item)
        }

        let orgFile = OrgFile.init(topComments: flattened.comments, outlines: graphContainer.allSubItems(of: graphContainer.root))

        return orgFile
    }


}


extension OrgParser {

    private func headingParser() -> Parser<OutlineHeading> {
        let p = (pstars ->> (pchar(" ") |> many1)) ->>- (anyCharacterBesidesNewLine |> many1) ->> newLine
        let pH = p |>> { OutlineHeading(title: String($1), depth: $0.count) }
        return pH <?> "Org Heading"
    }

    func comments() -> Parser<[String]> {
        let commentLine = pstring("#+") ->>- (anyCharacterBesidesNewLine |> many1) ->> (newLine |> many)
        let comments = commentLine |> parseUntil(headingParser())
        let formatted = comments.map { lines in
            return lines.map { "\($0.0)\(String($0.1))" }
        }
        return formatted
    }

    /// Run the parser Parser<U> unless the next stream is satisfied with Parser<T>
    private func parseUntil<T,U>(_ next: Parser<T>) -> (Parser<U>) -> Parser<[U]> {
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


    func contentParser() -> Parser<[String]> {
        let anyContent = (anyCharacterBesidesNewLine |> many) ->> newLine |>> {
            return $0.isEmpty ? "" : String($0)
        }
        let manyLines = anyContent |> parseUntil(headingParser())
        return manyLines <?> "Org Content"
    }

    private func outlineParser() -> Parser<OutlineTop.Item> {
        return headingParser() ->>- contentParser() |>> { OutlineTop.Item(heading: $0, content: $1) }
    }

}
