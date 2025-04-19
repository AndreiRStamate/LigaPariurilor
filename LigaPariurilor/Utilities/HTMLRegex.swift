//
//  HTMLRegex.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import Foundation

extension String {
    /// Cache compiled regular expressions to avoid recompilation
    private static var regexCache = [String: NSRegularExpression]()

    /// Returns substrings matching the given pattern.
    /// - Parameters:
    ///   - pattern: The regular expression pattern.
    ///   - options: Regex compilation options (default: []).
    ///   - group: Capture group index to extract (0 for whole match; default 1).
    func matches(
        for pattern: String,
        options: NSRegularExpression.Options = [],
        group: Int = 1
    ) -> [String] {
        // Compile or reuse cached regex
        let regex: NSRegularExpression
        if let cached = Self.regexCache["\(pattern)|\(options.rawValue)"] {
            regex = cached
        } else {
            do {
                let compiled = try NSRegularExpression(pattern: pattern, options: options)
                Self.regexCache["\(pattern)|\(options.rawValue)"] = compiled
                regex = compiled
            } catch {
                assertionFailure("Invalid regex pattern: \(error)")
                return []
            }
        }
        
        let nsString = self as NSString
        let matches = regex.matches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: nsString.length)
        )
        return matches.compactMap { match in
            guard match.numberOfRanges > group else { return nil }
            let range = match.range(at: group)
            return nsString.substring(with: range)
        }
    }
}
