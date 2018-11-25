import Foundation

extension Parser {
    
    /// Perform first match and then perform second match
    /// with the remainder from first match. Error is propagated
    /// if something goes wrong in any place.
    ///
    /// - Parameter nextParser: Parser<T>
    /// - Returns: Parser<(Output, T)> is a combined parser.
    public func andThen<T>(_ nextParser: Parser<T>) -> Parser<(Output,T)> {
        return self.flatMap { out1 in
            return nextParser.flatMap { out2 in
                let out = (out1, out2)
                return lift(out)
            }
        } <?> "'\(self.label)' andThen '\(nextParser.label)'"
    }
    
    public static func and<T,U>(_ first: Parser<T>, _ second: Parser<U>) -> Parser<(T,U)> {
        return first.andThen(second)
    }
    
    /// Parses the input with the first parser, if that succeeds
    /// returns it. Else, feeds in the input to the second parser
    /// and uses its return value. Its like || condition.
    ///
    /// - Parameter otherParser: Parser
    /// - Returns: Parser representing the OR combined
    public func orElse(_ otherParser: Parser) -> Parser {
        return Parser { input in
            let firstRun = self |> run(input)
            switch firstRun {
            case let .success(v):
                return .success(v)
            case .failure:
                return otherParser |> run(input)
            }
        } <?> "'\(self.label)' orElse '\(otherParser.label)'"
    }
    
    public static func orElse(firstParser: Parser, secondParser: Parser) -> Parser {
        return firstParser.orElse(secondParser)
    }
    
    
    /// Parses using both but ignore the output from
    /// second parser.
    ///
    /// - Parameters:
    ///   - rhs: Parser<T>
    /// - Returns: Parser<Output>
    public func keepLeft<T>( _ rhs: Parser<T>) -> Parser<Output> {
        return self.andThen(rhs) |>> { $0.0 }
    }
    
    /// Use both parses but ignore left's output
    ///
    /// - Parameters:
    ///   - rhs: Parser<T>
    /// - Returns: Parser<T>
    public func keepRight<T>(_ rhs: Parser<T>) -> Parser<T> {
        return self.andThen(rhs) |>> { $0.1 }
    }
    
    /// Parse the given input as many time as possible collecting the output.
    ///
    /// - Parameter input: Stream
    /// - Returns: ([Output], Stream)
    func parseZeroOrMore(_ input: Stream) -> ([Output], Stream) {
        let thisRun = self |> run(input)
        switch thisRun {
        case .failure:
            return ([], input)
        case let .success(v):
            let (subsequentValues, remainder) = parseZeroOrMore(v.1)
            let values = [v.0] + subsequentValues
            return (values, remainder)
        }
    }
    
}


/// Given a list of same typed parsers, reduce them into single parser
/// In the process, sequencing the parsed output in order
/// In case of empty parsers input, we return a identity parser on []
///
/// - Parameter parsers: [Parser<T>]
/// - Returns: Parser<[T]>
public func sequenceOutput<T>(_ parsers: [Parser<T>]) -> Parser<[T]> {
    guard let first = parsers.first else {
        return Parser<[T]> { input in
            let output = ([T](), input)
            return .success(output)
        }
    }
    
    let others: Parser<[T]> = sequenceOutput(Array(parsers.dropFirst()))
    let firstMapped: Parser<[T]> = first |>> { [$0] }
    let andThenned = firstMapped.andThen(others)
    return andThenned |>> { $0.0 + $0.1 } <?> "Sequence of '\(parsers.reduce("", { $0 + $1.label}))'"
}


/// Find the parser that works from the list
///
/// - Parameter parsers: [Parser<T>]
/// - Returns: Parser<T>
public func choice<T>(_ parsers: [Parser<T>]) -> Parser<T> {
    return parsers.foldl1(by: <|>)!
}


/// Matches using the parses as many times as possible.
/// The output will be sequenced into an array.
///
/// - Parameter parser: Parser<T>
/// - Returns: Parser<[T]>. This will be empty if there was no match.
public func many<T>(_ parser: Parser<T>)-> Parser<[T]> {
    return Parser<[T]> { input in
        return .success(parser.parseZeroOrMore(input))
    }
}


/// Parse given input 1 or more times
///
/// - Parameter parser: Parser<T>
/// - Returns: Parser<[T]>. If the parser matches none, it will error.
public func many1<T>(_ parser: Parser<T>) -> Parser<[T]> {
    return Parser<[T]> { input in
        let zeroOrMore = parser.parseZeroOrMore(input)
        guard !zeroOrMore.0.isEmpty else {
            return parser |>> { [$0] } |> run(input)
        }
        return .success(zeroOrMore)
    }
}


/// Match for optional existance. In case of match, the character is consumed as
/// like expected. When there is no, stream is not consumed.
///
/// - Parameter parser: Parser<T>
/// - Returns: Parser<T?>
public func optional<T>(_ parser: Parser<T>) -> Parser<T?> {
    return Parser<T?> { input in
        let thisRun = parser |> run(input)
        switch thisRun {
        case .failure:
            let out: (T?, Parser<T>.RemainingStream) = (nil, input)
            return .success(out)
        case let .success(v):
            let out: (T?, Parser<T>.RemainingStream) = (v.0, v.1)
            return .success(out)
        }
    }
}

/// Creates a parser which will match for parser separated by separator Parser
/// It expects to match atleast once
///
/// - Parameters:
///   - parser: Parser<T> include parser
///   - separator: Parser<T> separator parser
/// - Returns: Parser<[T]> list of matches
public func separated1<T>(_ parser: Parser<T>, by separator: Parser<T>) -> Parser<[T]> {
    let separatorThenP = separator >>- parser
    let manySepAndP = many(separatorThenP)
    let match = parser ->>- manySepAndP
    return match |>> { [$0.0] + $0.1 }
}


/// Creates a parser that matches for 0 or more times separated by given parser
///
/// - Parameters:
///   - parser: Parser<T> to include
///   - separator: Parser<T> to exclude/separate
/// - Returns: Parser<[T]> where [T] is the sequenced output
public func separated<T>(_ parser: Parser<T>, by separator: Parser<T>) -> Parser<[T]> {
    return separated1(parser, by: separator) <|> lift([T]())
}
