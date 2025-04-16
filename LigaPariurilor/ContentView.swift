//
//  ContentView.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 16.04.2025.
//

import SwiftUI

struct ContentView: View {
@StateObject private var viewModel = JSONViewModel()
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let content = viewModel.formattedText {
                ScrollView {
                    Text(content)
                        .padding()
                        .multilineTextAlignment(.leading)
                }
            } else if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let error = viewModel.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else {
                Text("No data loaded.")
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchJSON()
        }
    }
}

#Preview {
    ContentView()
}

class JSONViewModel: ObservableObject {
    @Published var formattedText: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchJSON() {
        guard let url = URL(string: "http://localhost:6969/files/api_response_soccer_uefa_champs_league.json") else {
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

                do {
                    _ = try JSONSerialization.jsonObject(with: data, options: [])
                    let matches = JSONMatchParser.parseMatches(from: data, league: "soccer_uefa_champs_league")

                    // Example: Convert match data to a displayable string (can customize later)
                    self.formattedText = matches.map { match in
                        "\(match.team1) vs \(match.team2)\nOdds: \(match.odds[match.team1]!) / \(match.odds[match.team2]!)\nDate: \(match.commenceTime)"
                    }.joined(separator: "\n\n")
                } catch {
                    self.errorMessage = "Failed to parse JSON"
                }
            }
        }.resume()
    }
}

import Foundation

struct Match: Identifiable {
    let id = UUID()
    let league: String
    let team1: String
    let team2: String
    let odds: [String: Double]
    let commenceTime: String
}

class JSONMatchParser {
    static func parseMatches(from data: Data, league: String) -> [Match] {
        guard let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
            print("Failed to decode JSON array")
            return []
        }

        var matches: [Match] = []

        for match in jsonArray {
            var team1: String?
            var team2: String?

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
                print("Skipping match due to missing odds")
                continue
            }

            let match = Match(
                league: league,
                team1: t1,
                team2: t2,
                odds: [t1: best1, t2: best2],
                commenceTime: commenceTime
            )

            matches.append(match)
        }

        return matches
    }
}
