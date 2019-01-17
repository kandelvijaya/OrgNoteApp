import Foundation

/// Posiiton of text
public struct ParserPosition: Equatable {
    /// line starting from 0
    let row: Int
    
    /// column starting from 0
    let col: Int
}


extension ParserPosition {
    
    /// initial position of a input text
    init() {
        self.row = 0
        self.col = 0
    }
    
    /// Increment column.
    /// This is line agnostic. It's upto the client to make sure
    /// that the line actually has this column
    func incrCol() -> ParserPosition {
        return ParserPosition(row: row, col: col + 1)
    }
    
    /// Increment row/line count.
    /// This is line agnostic. It's upto the client to make sure
    /// that the line actually has this row
    func incrRow() -> ParserPosition {
        return ParserPosition(row: row + 1, col: 0)
    }
    
}




/// Parser Input Representation
public struct InputState {
    /// Lines from the source text
    public let lines: [String]
    
    /// Current cursror / parser position
    public let position: ParserPosition
}


extension InputState {
    
    public static var EOF: String {
        return "end of file"
    }
    
    public init(from str: String) {
        var l = str.split(separator: "\n", omittingEmptySubsequences: false).map {
            return $0.isEmpty ? "" : String($0)
        }
        if str.hasSuffix("\n") {
            // for each n separator there are n+1 splits. We dont need the last one.
            // If we have a trailing "\n", we dont need the empty subsequence after the end.
            _ = l.popLast()
        }
        lines = Array(l)
        position = ParserPosition()
    }
    
    public var currentLine: String {
        guard position.row < lines.count else {
            return InputState.EOF
        }
        return lines[position.row]
    }
    
    /// Retrieve the next character.
    ///
    /// three cases
    /// 1) if line >= maxLine ->
    /// return EOF
    /// 2) if col less than line length ->
    /// return char at colPos, increment colPos
    /// 3) if col at line length ->
    /// return NewLine, increment linePos
    public func nextChar() -> (InputState, Character?) {
        guard position.row < lines.count else {
            return (self, nil)
        }
        
        let thisLine = lines[position.row]
        
        if position.col < thisLine.count {
            let state = InputState(lines: lines, position: position.incrCol())
            let char = thisLine[String.Index.init(encodedOffset: position.col)]
            return (state, char)
        } else /*can only be equal */{
            let state = InputState(lines: lines, position: position.incrRow())
            let char = Character("\n")
            return (state, char)
        }
    }
    
}


/// Represents the Position of parser
/// Especially useful for error reporting
public struct ParserErrorPosition: Equatable {
    let currentLine: String
    let row: Int
    let col: Int
}

extension InputState {
    func parserPosition() -> ParserErrorPosition {
        return ParserErrorPosition(currentLine: self.currentLine, row: self.position.row, col: self.position.col)
    }
}

