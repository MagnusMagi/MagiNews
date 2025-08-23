//
//  String+Extensions.swift
//  MagiNewsIOS
//
//  Created by Magnus Magi on 24.08.2025.
//

import Foundation
import UIKit

extension String {
    
    // MARK: - CDATA Cleaning
    
    /// Removes CDATA wrappers from RSS content
    /// Example: "<![CDATA[Article Title]]>" becomes "Article Title"
    var cleanedCDATA: String {
        let cdataPattern = "<!\\[CDATA\\[(.*?)\\]\\]>"
        let regex = try? NSRegularExpression(pattern: cdataPattern, options: [])
        
        if let regex = regex {
            let range = NSRange(location: 0, length: self.utf16.count)
            let cleanedString = regex.stringByReplacingMatches(
                in: self,
                options: [],
                range: range,
                withTemplate: "$1"
            )
            return cleanedString
        }
        
        return self
    }
    
    // MARK: - HTML Entity Decoding
    
    /// Decodes common HTML entities to readable text
    var htmlEntityDecoded: String {
        var decoded = self
        
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
            decoded = decoded.replacingOccurrences(of: entity, with: replacement)
        }
        
        // Handle numeric entities like &#8217;
        let numericPattern = "&#(\\d+);"
        if let regex = try? NSRegularExpression(pattern: numericPattern, options: []) {
            let range = NSRange(location: 0, length: decoded.utf16.count)
            decoded = regex.stringByReplacingMatches(
                in: decoded,
                options: [],
                range: range,
                withTemplate: ""
            )
            
            // Manual replacement for numeric entities
            let matches = regex.matches(in: decoded, options: [], range: range)
            for match in matches.reversed() {
                if let range = Range(match.range, in: decoded) {
                    let matchString = String(decoded[range])
                    if let numberString = matchString.dropFirst(2).dropLast(1).first,
                       let number = Int(String(numberString)),
                       let unicodeScalar = UnicodeScalar(number) {
                        decoded = decoded.replacingOccurrences(of: matchString, with: String(unicodeScalar))
                    }
                }
            }
        }
        
        return decoded
    }
    
    // MARK: - RSS Content Cleaning
    
    /// Comprehensive cleaning for RSS content (CDATA + HTML entities)
    var cleanedRSSContent: String {
        return self
            .cleanedCDATA
            .htmlEntityDecoded
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Truncation
    
    /// Truncates string to specified length with ellipsis
    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count <= length {
            return self
        }
        return String(self.prefix(length)) + trailing
    }
    
    // MARK: - Safe URL Validation
    
    /// Checks if string is a valid URL
    var isValidURL: Bool {
        guard let url = URL(string: self) else { return false }
        return UIApplication.shared.canOpenURL(url)
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
