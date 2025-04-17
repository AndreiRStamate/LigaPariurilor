//
//  JSONViewModel.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import SwiftUI

class JSONViewModel: ObservableObject {
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
    func fetchJSON(from fileName: String) {
        if let cachedData = loadFromCache(fileName: fileName) {
            parseJSON(cachedData)
            return
        }
        
        guard let url = URL(string: "\(APIConfig.baseURL)/files/\(fileName)") else {
            errorMessage = "Invalid URL"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                self.saveToCache(data, fileName: fileName)
                self.parseJSON(data)
            }
        }.resume()
    }
    
    func sortMatches() {
        switch sortMode {
        case .predictability:
            matches = allMatches.sorted { $0.predictability < $1.predictability }
        case .commenceTime:
            matches = allMatches.sorted {
                (ISO8601DateFormatter().date(from: $0.commenceTime) ?? .distantFuture) <
                (ISO8601DateFormatter().date(from: $1.commenceTime) ?? .distantFuture)
            }
        }
    }
}

fileprivate class JSONMatchParser {
    static func parseMatches(from data: Data) -> [Match] {
        guard let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
            print("Failed to decode JSON array")
            return []
        }

        var matches: [Match] = []

        for match in jsonArray {
            var team1: String?
            var team2: String?
            guard let league = match["sport_title"] as? String else {
                print("Skipping match due to missing league")
                continue
            }
            
            if let teams = match["teams"] as? [String], teams.count == 2 {
                team1 = teams[0]
                team2 = teams[1]
            } else {
                team1 = match["home_team"] as? String
                team2 = match["away_team"] as? String
            }

            guard let t1 = team1, let t2 = team2 else {
                print("Skipping match due to missing teams")
                continue
            }

            guard let commenceTime = match["commence_time"] as? String else {
                print("Skipping match due to missing commence_time")
                continue
            }

            var oddsTeam1: [Double] = []
            var oddsTeam2: [Double] = []

            if let bookmakers = match["bookmakers"] as? [[String: Any]] {
                for bookmaker in bookmakers {
                    if let markets = bookmaker["markets"] as? [[String: Any]] {
                        for market in markets {
                            if market["key"] as? String == "h2h" {
                                if let outcomes = market["outcomes"] as? [[String: Any]] {
                                    for outcome in outcomes {
                                        if let name = outcome["name"] as? String,
                                           let price = outcome["price"] as? Double {
                                            if name == t1 {
                                                oddsTeam1.append(price)
                                            } else if name == t2 {
                                                oddsTeam2.append(price)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            guard let best1 = oddsTeam1.min(), let best2 = oddsTeam2.min() else {
                print("Skipping \(t1) vs \(t2) due to missing odds")
                continue
            }

            let match = Match(
                league: league,
                team1: t1,
                team2: t2,
                odds: [t1: best1, t2: best2],
                commenceTime: commenceTime,
                predictability: abs(best1 - best2),
                action: abs(best1 - best2) < 1.0 ? "PARIU SIGUR" : "PARIU RISCANT"
            )

            matches.append(match)
        }

        return matches
    }
}
