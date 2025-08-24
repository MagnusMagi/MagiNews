//
//  String+Extensions.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import Foundation
import UIKit

extension String {
    
    // MARK: - RSS Content Cleaning
    
    /// Removes CDATA wrappers and decodes HTML entities from RSS content
    var cleanedRSSContent: String {
        self
            .removingCDATA
            .decodingHTMLEntities
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Removes CDATA wrappers: <![CDATA[...]]>
    private var removingCDATA: String {
        let cdataPattern = "<!\\[CDATA\\[(.*?)\\]\\]>"
        return self.replacingOccurrences(
            of: cdataPattern,
            with: "$1",
            options: .regularExpression
        )
    }
    
    /// Decodes common HTML entities
    private var decodingHTMLEntities: String {
        var result = self
        
        // Common HTML entities
        let entities = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&#39;": "'",
            "&apos;": "'",
            "&nbsp;": " ",
            "&hellip;": "...",
            "&mdash;": "—",
            "&ndash;": "–",
            "&lsquo;": "'",
            "&rsquo;": "'",
            "&ldquo;": "\"",
            "&rdquo;": "\"",
            "&copy;": "©",
            "&reg;": "®",
            "&trade;": "™"
        ]
        
        for (entity, replacement) in entities {
            result = result.replacingOccurrences(of: entity, with: replacement)
        }
        
        // Handle numeric entities like &#8217;
        let numericPattern = "&#(\\d+);"
        if let regex = try? NSRegularExpression(pattern: numericPattern, options: []) {
            let range = NSRange(location: 0, length: result.utf16.count)
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: range,
                withTemplate: ""
            )
            
            // Manual replacement for numeric entities
            let matches = regex.matches(in: result, options: [], range: range)
            for match in matches.reversed() {
                if let range = Range(match.range, in: result) {
                    let matchString = String(result[range])
                    if let numberString = matchString.dropFirst(2).dropLast(1).first,
                       let number = Int(String(numberString)),
                       let unicodeScalar = UnicodeScalar(number) {
                        result = result.replacingOccurrences(of: matchString, with: String(unicodeScalar))
                    }
                }
            }
        }
        
        return result
    }
    
    // MARK: - Text Processing
    
    /// Truncates text to specified length with ellipsis
    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        }
        return self
    }
    
    /// Extracts first sentence from text
    var firstSentence: String {
        let sentences = self.components(separatedBy: [".", "!", "?"])
        return sentences.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? self
    }
    
    /// Removes HTML tags from text
    var removingHTMLTags: String {
        return self.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        )
    }
    
    // MARK: - Validation
    
    /// Checks if string is a valid URL
    var isValidURL: Bool {
        guard let url = URL(string: self) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    /// Checks if string contains only whitespace
    var isWhitespaceOnly: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Regex Match Helper

private extension NSTextCheckingResult {
    var capturedGroups: [String] {
        var groups: [String] = []
        for i in 1..<numberOfRanges {
            if let range = Range(range(at: i), in: "") {
                groups.append(String(describing: range))
            }
        }
        return groups
    }
    
    var fullMatch: String {
        if let range = Range(range, in: "") {
            return String(describing: range)
        }
        return ""
    }
}
