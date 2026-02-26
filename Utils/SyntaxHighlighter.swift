//
//  SyntaxHighlighter.swift
//  TorisExam
//
//  Created by Kartikay on 27/02/26.
//

import SpriteKit

#if canImport(UIKit)
    import UIKit
    typealias PlatformColor = UIColor
    typealias PlatformFont = UIFont
#else
    import AppKit
    typealias PlatformColor = NSColor
    typealias PlatformFont = NSFont
#endif

struct SyntaxHighlighter {

    static let keywords: [String] = [
        "class", "func", "var", "let", "private", "public",
        "protocol", "return", "if", "else", "true", "false",
        "nil", "import",
    ]

    static let keywordColor = PlatformColor(red: 0.8, green: 0.4, blue: 0.6, alpha: 1.0)
    static let defaultColor = PlatformColor.green
    static let stringColor = PlatformColor(red: 0.9, green: 0.8, blue: 0.4, alpha: 1.0)
    static let commentColor = PlatformColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)

    static func highlight(_ code: String, fontName: String = "Menlo", fontSize: CGFloat = 16)
        -> NSAttributedString
    {

        let attributedString = NSMutableAttributedString(string: code)
        let fullRange = NSRange(location: 0, length: code.utf16.count)

        if let font = PlatformFont(name: fontName, size: fontSize) {
            attributedString.addAttribute(.font, value: font, range: fullRange)
        }

        attributedString.addAttribute(.foregroundColor, value: defaultColor, range: fullRange)

        for keyword in keywords {
            let pattern = "\\b\(keyword)\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let matches = regex.matches(in: code, options: [], range: fullRange)
                for match in matches {
                    attributedString.addAttribute(
                        .foregroundColor, value: keywordColor, range: match.range)
                }
            }
        }

        let stringPattern = "\".*?\""
        if let regex = try? NSRegularExpression(pattern: stringPattern, options: []) {
            let matches = regex.matches(in: code, options: [], range: fullRange)
            for match in matches {
                attributedString.addAttribute(
                    .foregroundColor, value: stringColor, range: match.range)
            }
        }

        let commentPattern = "//.*"
        if let regex = try? NSRegularExpression(pattern: commentPattern, options: []) {
            let matches = regex.matches(in: code, options: [], range: fullRange)
            for match in matches {
                attributedString.addAttribute(
                    .foregroundColor, value: commentColor, range: match.range)
            }
        }

        return attributedString
    }
}
