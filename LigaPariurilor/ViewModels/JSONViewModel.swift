//
//  JSONViewModel.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import SwiftUI

class JSONViewModel: ObservableObject {
    
    private let fetcher: JSONFetching
    private let cache:   CacheManaging
    private let decoder: MatchDecoding

    init(fetcher: JSONFetching = URLSessionJSONFetcher(),
       cache:   CacheManaging   = FileCacheManager(),
       decoder: MatchDecoding   = JSONMatchDecoder())
    {
    self.fetcher = fetcher
    self.cache   = cache
    self.decoder = decoder
    }
    
    @Published var matches: [Match] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @AppStorage("sortMode") var sortMode: SortMode = .predictability
    @Published private var allMatches: [Match] = []

    private func cacheURL(for fileName: String) -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName)
    }
    
    private func saveToCache(_ data: Data, fileName: String) {
        guard let url = cacheURL(for: fileName) else { return }
        try? data.write(to: url)
    }
    
    private func loadFromCache(fileName: String) -> Data? {
        guard let url = cacheURL(for: fileName),
              FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try? Data(contentsOf: url)
    }
    
    private func parseJSON(_ data: Data) {
        do {
            _ = try JSONSerialization.jsonObject(with: data, options: [])
            let matches = JSONMatchParser.parseMatches(from: data)
            self.allMatches = matches
            self.sortMatches()
        } catch {
            self.errorMessage = "Failed to parse JSON"
        }
    }
    
    /// Reusable ISO8601 date formatter
    private static let isoFormatter = ISO8601DateFormatter()

    /// Parse a match’s commenceTime string into Date
    private func date(from isoString: String) -> Date? {
        Self.isoFormatter.date(from: isoString)
    }

    /// Return allMatches sorted according to the current sortMode
    private func sortedMatchesArray() -> [Match] {
        switch sortMode {
        case .predictability:
            return allMatches.sorted { $0.predictability < $1.predictability }
        case .commenceTime:
            return allMatches.sorted {
                (date(from: $0.commenceTime) ?? .distantFuture) <
                (date(from: $1.commenceTime) ?? .distantFuture)
            }
        }
    }

    func fetchJSON(from fileName: String, url: URL) {
      if let data = cache.load(fileName: fileName) {
        apply(data)
        return
      }
      isLoading = true
      errorMessage = nil

      fetcher.fetch(fileName: fileName, from: url) { result in
        DispatchQueue.main.async {
          self.isLoading = false
          switch result {
          case .failure(let err):
            self.errorMessage = err.localizedDescription
          case .success(let data):
            self.cache.save(data, fileName: fileName)
            self.apply(data)
          }
        }
      }
    }

    private func apply(_ data: Data) {
      do {
        let matches = try decoder.decode(data)
        self.allMatches = matches
        sortMatches()
      } catch {
        self.errorMessage = error.localizedDescription
      }
    }
    
    func sortMatches() {
        matches = sortedMatchesArray()
    }

    var hasPastMatches: Bool {
        sortedMatchesArray().contains { match in
            guard let matchDate = date(from: match.commenceTime) else { return false }
            return matchDate <= Date()
        }
    }

    func filteredMatches(showPast: Bool) -> [Match] {
        let sortedMatches = sortedMatchesArray()
        return sortedMatches.filter { match in
            guard let matchDate = date(from: match.commenceTime) else { return false }
            return showPast || matchDate > Date()
        }
    }

    func displayName(from fileName: String) -> String {
        let trimmed = fileName
            .replacingOccurrences(of: "api_response_", with: "")
            .replacingOccurrences(of: ".json", with: "")
        return (LeagueInfo.names[trimmed] ?? trimmed).uppercased()
    }
}
