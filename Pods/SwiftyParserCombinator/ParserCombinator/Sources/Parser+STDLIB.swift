import Foundation


// MARK:- primitive

public let whitespacces = ["\t", " ", "\n", "\r"].joined()
public let plowercase = allAlphabets.lowercased() |> anyOfChars <?> "lowercase alphabets"
public let puppercase = allAlphabets.uppercased() |> anyOfChars <?> "uppercase alphabets"
public let pdigit = satisfy({ $0.isDigit }, label: "Digits") |>> { Int(String($0))! } <?> "Digits"
public let pwhitespace = whitespacces |> anyOfChars <?> "Whitespaces"

public var allAlphabets: String {
    let temp = "abcdefghijklmnopqrstuvwxyz"
    assert(temp.count == 26)
    return temp
}


public var digits: String {
    let temp = "0123456789"
    assert(temp.count == 10)
    return temp
}


// MARK:- Character Parser
public func satisfy(_ predicate: @escaping (Character) -> Bool, label: Parser<Any>.Label) -> Parser<Character> {
    return Parser<Character> { str in
        switch str.nextChar() {
        case (let state, let char?):
            if predicate(char) {
                return .success((char, state))
            } else {
                return .failure(error(label, "Unexpected '\(char)'", state.parserPosition()))
            }
        case (let state, nil):
            return .failure(error(label, "stream is empty", state.parserPosition()))
        }
    } <?> label
}

/// Parser to match a single character.
///
/// - Parameter charToMatch: Character
/// - Returns: Parser<Character>
public func pchar(_ character: Character) -> Parser<Character> {
    let predicate = { $0 == character}
    let label = "\(character)"
    return satisfy(predicate, label: label)
}


/// Gets a parser that matches any of the character in the string.
///
/// - Parameter string: String
/// - Returns: Parser<Character>
public func anyOfChars(_ string: String) -> Parser<Character> {
    return string.map(pchar) |> choice <?> "Any of \(string)"
}


/// Parser to match a provided String
///
/// - Parameter match: String
/// - Returns: Parser<String>
public func pstring(_ stringToMatch: String) -> Parser<String> {
    return stringToMatch.map(pchar) |> sequenceOutput |>> { String($0) } <?> stringToMatch
}

/// Match a quoted string. It will fail to match a string that
/// doesnot have doublequotes around.
///
/// - Parameter match: String containing double quotes
/// - Returns: Parser<String>
public func pquotedString(_ match: String) -> Parser<String> {
    let quoteMatcher = pchar("\"") |>> { String($0) }
    return quoteMatcher >>- pstring(match) ->> quoteMatcher <?> match
}


/// Parser for signed and unsigned Int
public var pint: Parser<Int> {
    let pminus = pchar("-") |> optional
    let manyDigitMatcher = digits.map(pchar) |> choice |> many1 |>> { Int(String($0))! }
    let optSignedInt = pminus ->>- manyDigitMatcher
    return optSignedInt |>> { (charO, int) in
        return charO.map{_ in -int } ?? int
        } <?> "Integer"
}

/// Parser for float
public var pfloat: Parser<Float> {
    // (opt sign) (digits many1) (pdot) (digits many)
    let optSign = (pchar("-") |> optional)
    let leftDigits = (digits.map(pchar) |> choice |> many1)
    let rightDigits = leftDigits
    let dot = pchar(".")
    
    /// ->>- combinator produces output of (A, B) to represent
    /// heterogeneous collection in pair.
    /// ((A,B),C) == (A,B,C)
    let parser = (optSign ->>- leftDigits ->>- dot ->>- rightDigits).map {
        return ($0.0.0.0, $0.0.0.1, $0.0.1, $0.1)
    }
    
    return parser.map {
        let floatStr = String($0.1) + String($0.2) + String($0.3)
        let signMultiplier: Float = ($0.0 == nil ? 1 : -1)
        let float = Float(floatStr)! * signMultiplier
        return float
        } <?> "float"
}


/// manyChars
public func manyChar(_ charP: Parser<Character>) -> Parser<String> {
    return charP |> many |>> { String($0) }
}

/// many1Chars
public func many1Char(_ charP: Parser<Character>) -> Parser<String> {
    return charP |> many1 |>> { String($0) }
}


/// manySpaces
public let manySpaces = whitespacces |> anyOfChars |> many |>> { String($0) }

/// many1Spaces
public let many1Spaces = whitespacces |> anyOfChars |> many1 |>> {String($0)}
