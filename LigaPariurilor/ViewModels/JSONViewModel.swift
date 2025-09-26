//
//  JSONViewModel.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import SwiftUI

class JSONViewModel: ObservableObject {
    
    private let fetcher: JSONFetching
    private let decoder: MatchDecoding

    init(fetcher: JSONFetching = URLSessionJSONFetcher(),
         decoder: MatchDecoding   = JSONMatchDecoder())
    {
    self.fetcher = fetcher
    self.decoder = decoder
    }
    
    @Published var matches: [Match] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @AppStorage("sortMode") var sortMode: SortMode = .predictability
    @Published private var allMatches: [Match] = []
    
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
        if let data = CacheService.load(fileName: fileName, expiry: nil) {
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
              CacheService.save(data, fileName: fileName, updateMeta: false)
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

    var hasBets: Bool {
        sortedMatchesArray().contains { match in
            Bet.checkIfFileExists(match: match.matchId)
        }
    }

    func filteredMatches(showPast: Bool, onlyWithBets: Bool = false) -> [Match] {
        let sortedMatches = sortedMatchesArray()
        return sortedMatches.filter { match in
            guard let matchDate = date(from: match.commenceTime) else { return false }
            let isFuture = matchDate > Date()
            let hasBets = Bet.checkIfFileExists(match: match.matchId)
            return (showPast || isFuture) && (!onlyWithBets || hasBets)
        }
    }

    func displayName(from fileName: String) -> String {
        let trimmed = fileName.trimmedFilename
        return (LeagueInfo.names[trimmed] ?? trimmed).uppercased()
    }
}

