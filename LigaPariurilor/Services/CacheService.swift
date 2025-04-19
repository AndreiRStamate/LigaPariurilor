//
//  CacheService.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import Foundation

struct CacheService: CacheManaging{
    
    private let folder: URL

    init(documentDirectory: URL = FileManager.default
           .urls(for: .documentDirectory, in: .userDomainMask).first!) {
      self.folder = documentDirectory
    }

    func load(fileName: String) -> Data? {
      let url = folder.appendingPathComponent(fileName)
      return FileManager.default.fileExists(atPath: url.path)
        ? try? Data(contentsOf: url)
        : nil
    }

    func save(_ data: Data, fileName: String) {
      let url = folder.appendingPathComponent(fileName)
      try? data.write(to: url)
    }
    
    // Cache expiry settings
    static let fullCacheExpiry: TimeInterval = 24 * 60 * 60  // 24 hours
    static let staleThreshold: TimeInterval = 12 * 60 * 60   // 12 hours
    
    static func loadCachedFiles() -> [LeagueFile] {
        let fileManager = FileManager.default
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }
        
        do {
            let jsonFiles = try fileManager.contentsOfDirectory(atPath: directory.path)
                .filter { $0.hasSuffix(".json") }
            let mappedFiles = jsonFiles.map { file in
                let trimmed = file
                    .replacingOccurrences(of: "api_response_", with: "")
                    .replacingOccurrences(of: ".json", with: "")
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
        
        if let cachedDate = getCachedDate(for: fileName) {
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
                saveToCache(data, fileName: fileName)
            }
        }.resume()
    }
    
    private static func getCachedDate(for fileName: String) -> Date? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let metaURL = dir.appendingPathComponent(fileName).appendingPathExtension("meta")
        if let metaData = try? Data(contentsOf: metaURL),
           let json = try? JSONSerialization.jsonObject(with: metaData) as? [String: Any],
           let timestamp = json["cachedAt"] as? TimeInterval {
            return Date(timeIntervalSince1970: timestamp)
        }
        return nil
    }
    
    static func saveToCache(_ data: Data, fileName: String) {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(fileName) else { return }
        try? data.write(to: url)
        let metadata = ["cachedAt": Date().timeIntervalSince1970]
        if let metaData = try? JSONSerialization.data(withJSONObject: metadata) {
            try? metaData.write(to: url.appendingPathExtension("meta"))
        }
    }
    
    static func loadFromCache(fileName: String) -> Data? {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(fileName),
              FileManager.default.fileExists(atPath: url.path) else { return nil }
        let metaURL = url.appendingPathExtension("meta")
        if let metaData = try? Data(contentsOf: metaURL),
           let json = try? JSONSerialization.jsonObject(with: metaData) as? [String: Any],
           let timestamp = json["cachedAt"] as? TimeInterval {
            let age = Date().timeIntervalSince1970 - timestamp
            if age > fullCacheExpiry {
                return nil
            }
        }
        return try? Data(contentsOf: url)
    }
    
    static func isStale(fileName: String) -> Bool {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return false }
        let metaURL = dir.appendingPathComponent(fileName).appendingPathExtension("meta")
        if let metaData = try? Data(contentsOf: metaURL),
           let json = try? JSONSerialization.jsonObject(with: metaData) as? [String: Any],
           let timestamp = json["cachedAt"] as? TimeInterval {
            let age = Date().timeIntervalSince1970 - timestamp
            return age > staleThreshold
        }
        return false
    }
}
