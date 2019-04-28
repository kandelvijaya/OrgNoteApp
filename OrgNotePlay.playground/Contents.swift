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

func findLineNumber(on cursorCount: Int, in text: String) -> Int {
    var currentLineNo: Int = 0
    for (index, item) in text.enumerated() {
        if index == cursorCount {
            break
        }
        if item == Character("\n") {
            currentLineNo += 1
        }
    }
    
    return currentLineNo
}

func findLine(on cursorPos: Int, in string: String) -> (Int, String) {
    let lineNo = findLineNumber(on: cursorPos, in: string)
    return (lineNo, String(string.split(separator: "\n", omittingEmptySubsequences: false)[lineNo]))
}


func replaceLine(old: NSAttributedString, with new: NSAttributedString, at cursorPos: Int) -> NSAttributedString {
    let lineInfo = findLine(on: cursorPos, in: old.string)
    /// this might be ambigious if the same line exists on top
    let oldRange = (old.string as NSString).range(of: lineInfo.1)
    let oldCopy = NSMutableAttributedString.init(attributedString: old)
    oldCopy.replaceCharacters(in: oldRange, with: oldCopy)
    return oldCopy
}



findLineNumber(on: 7, in: string)
findLineNumber(on: 17, in: string)

findLine(on: 17, in: string)


"\n\n\n".split(separator: "\n", omittingEmptySubsequences: false)
