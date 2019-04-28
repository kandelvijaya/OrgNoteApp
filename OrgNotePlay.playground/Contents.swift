import UIKit
import PlaygroundSupport



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

let view = UITextView(frame: .init(x: 0, y: 0, width: 400, height: 300))
view.text = string



struct OrgHighlighter {
    
    private let input: String
    
    init(with input: String) {
        self.input = input
    }
    
    func orgHighlight() -> NSAttributedString {
        return highlightHeadings(input)
    }
    
    func headingAttributes(depth: UInt) -> [NSAttributedString.Key: Any] {
        let color: UIColor
        switch depth {
        case 1:
            color = .cyan
        case 2:
            color = .green
        case 3:
            color = .blue
        case 4:
            color = .brown
        default:
            color = .magenta
        }
        return [NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0)]
    }
    
    private func highlightHeadings(_ raw: String) -> NSAttributedString {
        
        // could use parser combintor
        let regex = try! NSRegularExpression(pattern: "^(\\*+)( +).*", options: [.caseInsensitive, .anchorsMatchLines])
        let searchRange = NSMakeRange(0, string.utf16.count)
        let mataches = regex.matches(in: raw, options: .init(rawValue: 0), range: searchRange)
        
        let attributedString = NSMutableAttributedString.init(string: raw)
        
        mataches.forEach { item in
            guard item.range != NSMakeRange(NSNotFound, 0) else { return }
            guard item.resultType == .regularExpression else {return }
            let fullrange = item.range
            
            /// replace * with beautiful emojied star
            let firstStarsRange = item.range(at: 1)
            let starsCount = firstStarsRange.length
            let stars = Array<String>.init(repeating: "✦", count: starsCount).joined()
            attributedString.replaceCharacters(in: firstStarsRange, with: stars)
            
            /// apply color depending on the heading depth
            attributedString.addAttributes(headingAttributes(depth: UInt(starsCount)), range: fullrange)
        }
        
        return attributedString
    }
    
}


let highlighted = OrgHighlighter(with: string).orgHighlight()

view.attributedText = highlighted



PlaygroundPage.current.liveView = view
