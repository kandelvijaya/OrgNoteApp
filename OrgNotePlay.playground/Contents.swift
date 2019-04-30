import UIKit
import PlaygroundSupport
import EnablePlaygroundShare



let string =
"""
* Ideas
** Work


1. Work on AppCraft and learn about Elm language
2. Make a project on Elm language to get more understanding
** Personal
Personal is divided into 3 segments:
*** Marriage [TODO]
*** Self
*** Travel
"""


let rangeTop = Range<String.Index>.init(NSRange(location: 0, length: 0), in: string)!
let rangeBottom = Range.init(NSRange(location: string.count, length: 0), in: string)!
let rangeMiddleEmptyLine = Range.init(NSRange(location: 16, length: 0), in: string)!

let line = string.lineRange(for: rangeMiddleEmptyLine)
print(string[line])


// INTERVIEW QUESTION:
func findLineRange(on cursorPosition: Int, in text: String) -> Range<String.Index> {
    
    let cursorIndexInText = String.Index(encodedOffset: cursorPosition)
    
    // upper limit
    var currentPosition: String.Index = cursorIndexInText
    var upperPosition: String.Index? = nil
    var lowerPosition: String.Index? = nil
    while upperPosition == nil {
        if currentPosition < text.endIndex {
            if text[currentPosition] == Character("\n") {
                upperPosition = currentPosition
            }
            currentPosition = text.index(after: currentPosition)
        } else {
            // EOF
            upperPosition = text.endIndex
        }
    }
    
    currentPosition = cursorIndexInText
    
    // lower limit
    while lowerPosition == nil {
        if currentPosition == text.startIndex {
            lowerPosition = text.startIndex
        } else {
            if text[currentPosition] == Character("\n") {
                lowerPosition = currentPosition
            }
            currentPosition = text.index(before: currentPosition)
        }
        
    }
    
    return Range(uncheckedBounds: (lower: lowerPosition!, upper: upperPosition!))
}
