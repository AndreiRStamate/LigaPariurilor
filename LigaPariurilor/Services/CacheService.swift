//
//  CacheService.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import Foundation

struct CacheService: CacheManaging{
    
    // Cache expiry settings
    static let fullCacheExpiry: TimeInterval = 24 * 60 * 60  // 24 hours
    static let staleThreshold: TimeInterval = 12 * 60 * 60   // 12 hours

    /// Directory used for storing cache files
    private static let folder: URL = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)
        .first!

    /// Returns the URLs for the data file and its corresponding .meta file
    private static func cacheURLs(for fileName: String) -> (dataURL: URL, metaURL: URL) {
        let dataURL = folder.appendingPathComponent(fileName)
        let metaURL = dataURL.appendingPathExtension("meta")
        return (dataURL, metaURL)
    }

    /// Reads and parses the .meta JSON file, returning the cachedAt date if available.
    private static func readCachedAt(from metaURL: URL) -> Date? {
        guard let metaData = try? Data(contentsOf: metaURL),
              let json = try? JSONSerialization.jsonObject(with: metaData) as? [String: Any],
              let timestamp = json["cachedAt"] as? TimeInterval else {
            return nil
        }
        return Date(timeIntervalSince1970: timestamp)
    }

    /// Loads data for the given file, optionally enforcing an expiry interval in seconds.
    static func load(fileName: String, expiry: TimeInterval?) -> Data? {
        let (dataURL, metaURL) = cacheURLs(for: fileName)
        // If an expiry is provided, check metadata age
        if let expiry = expiry, let cachedAt = Self.readCachedAt(from: metaURL) {
            let age = Date().timeIntervalSince(cachedAt)
            if age > expiry {
                return nil
            }
        }
        // Ensure data file exists
        guard FileManager.default.fileExists(atPath: dataURL.path) else {
            return nil
        }
        return try? Data(contentsOf: dataURL)
    }

    /// Saves data for the given file, and updates metadata if requested.
    static func save(_ data: Data, fileName: String, updateMeta: Bool) {
        let (dataURL, metaURL) = cacheURLs(for: fileName)
        // Write data file
        try? data.write(to: dataURL)
        // Optionally write/update metadata
        if updateMeta {
            let metadata: [String: TimeInterval] = ["cachedAt": Date().timeIntervalSince1970]
            if let metaData = try? JSONSerialization.data(withJSONObject: metadata) {
                try? metaData.write(to: metaURL)
            }
        }
    }

    static func loadCachedFiles() -> [LeagueFile] {
        let fileManager = FileManager.default
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }
        
        do {
            let jsonFiles = try fileManager.contentsOfDirectory(atPath: directory.path)
                .filter { $0.hasSuffix(".json") }
            let mappedFiles = jsonFiles.map { file in
                let trimmed = file.trimmedFilename
                let displayName = LeagueInfo.names[trimmed] ?? trimmed
                let region = LeagueInfo.region(for: trimmed)
                return LeagueFile(fileName: file, leagueKey: trimmed, displayName: displayName, region: region)
            }
            let sortedFiles = mappedFiles.sorted { lhs, rhs in
                if lhs.region != rhs.region {
                    return lhs.region < rhs.region
                }
                return lhs.displayName < rhs.displayName
            }
            return sortedFiles
        } catch {
            print("Error reading cached files: \(error)")
            return []
        }
    }
    
    static func fetchAndCacheFile(_ fileName: String, url: URL) {
        let fileURL = url.appendingPathComponent(fileName)
        var request = URLRequest(url: fileURL)
        
        let (_, metaURL) = cacheURLs(for: fileName)
        if let cachedDate = Self.readCachedAt(from: metaURL) {
            let formatter = DateFormatter()
            formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss zzz"
            formatter.locale = Locale(identifier: "en_US")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            request.setValue(formatter.string(from: cachedDate), forHTTPHeaderField: "If-Modified-Since")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 304 {
                // Refresh cache timestamp
                guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                let metaURL = dir.appendingPathComponent(fileName).appendingPathExtension("meta")
                let metadata = ["cachedAt": Date().timeIntervalSince1970]
                if let metaData = try? JSONSerialization.data(withJSONObject: metadata) {
                    try? metaData.write(to: metaURL)
                }
                return
            }
            
            if let data = data {
                save(data, fileName: fileName, updateMeta: true)
            }
        }.resume()
    }
    
    static func isStale(fileName: String) -> Bool {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        let metaURL = dir.appendingPathComponent(fileName).appendingPathExtension("meta")
        if let cachedDate = readCachedAt(from: metaURL) {
            let age = Date().timeIntervalSince(cachedDate)
            return age > staleThreshold
        }
        return false
    }
}
