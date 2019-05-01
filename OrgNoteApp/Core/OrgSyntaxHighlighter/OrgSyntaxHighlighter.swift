//
//  OrgSyntaxHighlighter.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 26.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit
import Kekka

extension UIColor {
    
    /// All the red, green and blue are bounded to 0 - 256.
    /// TODO:- Make a enum with strong cases for 255 possible values.
    static func color(red: Int, green: Int, blue: Int) -> UIColor {
        assertIsBounded(value: red)
        assertIsBounded(value: green)
        assertIsBounded(value: blue)
        return UIColor(displayP3Red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1)
        
    }
    
    static func assertIsBounded(value: Int) {
        assert(value > 0 && value < 256, "The value is not color bounded")
    }
    
    static var H1: UIColor {
        return .color(red: 82, green: 152, blue: 213)
    }
    
    static var H2: UIColor {
        return .color(red: 51, green: 145, blue: 115)
    }
    
    static var H3: UIColor {
        return .color(red: 103, green: 171, blue: 44)
    }
    
    static var H4: UIColor {
        return .color(red: 203, green: 147, blue: 148)
    }
    
    static var normal: UIColor {
        return .color(red: 170, green: 170, blue: 170)
    }
    
    static var orgDarBackground: UIColor {
        return .color(red: 41, green: 43, blue: 46)
    }
    
}

public struct OrgHighlighter {
    
    enum Symbol: String {
        case heading = "✦"
        case rawHeading = "*"
    }
    
    public init() {}
    
    public func plainText(from input: NSAttributedString) -> String {
        let plainText = input.string
        return plainText.replacingOccurrences(of: Symbol.heading.rawValue, with: Symbol.rawHeading.rawValue)
    }
    
    public func highlight(_ input: String) -> NSAttributedString {
        return NSAttributedString.init(string: input) |> highlightNormal |> highlightHeadings
    }
    
    func headingAttributes(depth: UInt) -> [NSAttributedString.Key: Any] {
        let color: UIColor
        switch depth {
        case 1:
            color = .H1
        case 2:
            color = .H2
        case 3:
            color = .H3
        case 4:
            color = .H4
        default:
            color = .normal
        }
        return [NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0)]
    }
    
    private func highlightNormal(_ raw: NSAttributedString) -> NSAttributedString {
        let attributedString = NSMutableAttributedString.init(attributedString: raw)
        try! OrgPattern.contentMatch.findMatches(in: raw.string) { item in
            attributedString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.normal], range: item.range)
        }
        return attributedString
    }
    
    private func highlightHeadings(_ raw: NSAttributedString) -> NSAttributedString {
        let attributedString = NSMutableAttributedString.init(attributedString: raw)
        
        try! OrgPattern.headingMatch.findMatches(in: raw.string) { item in
            let fullrange = item.range
            
            /// replace * with beautiful emojied star
            let firstStarsRange = item.range(at: 1)
            let starsCount = firstStarsRange.length
            let stars = Array<String>.init(repeating: Symbol.heading.rawValue, count: starsCount).joined()
            attributedString.replaceCharacters(in: firstStarsRange, with: stars)
            
            /// apply color depending on the heading depth
            attributedString.addAttributes(self.headingAttributes(depth: UInt(starsCount)), range: fullrange)
        }
    
        return attributedString
    }
    
}



enum OrgPattern: String {
    case contentMatch = "^(([^*]+)|(\\*+)[^ ]\\w.*)"
    case headingMatch = "^(\\*+)( +).*"
    
    func findMatches(in input: String, performing: @escaping (NSTextCheckingResult) -> Void) throws {
        let regex = try NSRegularExpression(pattern: self.rawValue, options: [.caseInsensitive, .anchorsMatchLines])
        regex.allMatches(in: input).filteredValidRegexpMatch.forEach(performing)
    }
    
}


extension NSRegularExpression {
    
    func allMatches(in string: String) -> [NSTextCheckingResult] {
        let searchRange = NSMakeRange(0, string.utf16.count)
        let matchs = self.matches(in: string, options: .init(rawValue: 0), range: searchRange)
        return matchs
    }
    
}

extension Array where Element: NSTextCheckingResult {
    
    var filteredValidRegexpMatch: [NSTextCheckingResult] {
        return self.compactMap { item -> NSTextCheckingResult? in
            guard item.range != NSMakeRange(NSNotFound, 0) else { return nil }
            guard item.resultType == .regularExpression else {return nil }
            return item
        }
    }
    
}
