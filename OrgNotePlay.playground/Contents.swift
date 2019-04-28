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

let view = UITextView(frame: .init(x: 0, y: 0, width: 400, height: 300))
view.text = string


let highlightedText = OrgHighlighter().orgHighlight(string)
view.attributedText = highlightedText


PlaygroundPage.current.liveView = view
