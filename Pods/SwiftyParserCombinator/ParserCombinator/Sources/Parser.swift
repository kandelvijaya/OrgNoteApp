import Foundation

public struct Parser<Output> {
    public typealias Stream = InputState
    public typealias Label = String
    public typealias RemainingStream = InputState
    public typealias ParsedOutput = ParserResult<(Output, RemainingStream)>
    
    public let parse: (Stream) -> ParsedOutput
    public var label: Label = ""
    
    public init(parse: @escaping (Stream) -> ParsedOutput) {
        self.parse = parse
    }
    
    public init(parse: @escaping (Stream) -> ParsedOutput, label: String) {
        self.parse = parse
        self.label = label
    }
    
}


/// Tag the parser with certain label. This is often
/// useful for debugging and seeing why parsing went wrong.
/// The function semantically doesnot change the parser at all.
/// It only inserts the tag in case this would fail.
///
/// - Parameters:
///   - parser: Parser<T>
///   - label: String to tag
/// - Returns: Parser<T>
public func setLabel<T>(_ parser: Parser<T>, _ label: String) -> Parser<T> {
    return Parser<T> (parse: { input in
        let prun = parser |> run(input)
        switch prun {
        case let .success(v):
            return .success(v)
        case let .failure(e):
            let out = error(label, e.error, e.position)
            return .failure(out)
        }
    }, label: label)
}

infix operator <?>: ApplicationPrecedenceGroup
public func <?><T>(_ parser: Parser<T>, _ label: String) -> Parser<T> {
    return setLabel(parser, label)
}


/// InputStream to run the parser against.
///
/// - Parameter input: The parser to use to match.
/// - Returns: Result<(Output, RemainingStream)>
public func run<T>(_ input: Parser<T>.Stream) -> (Parser<T>) -> Parser<T>.ParsedOutput {
    return { parser in
        return parser.parse(input)
    }
}

public func run<T>(_ input: String) -> (Parser<T>) -> Parser<T>.ParsedOutput {
    let state = input |> InputState.init
    return { parser in
        return parser.parse(state)
    }
}

