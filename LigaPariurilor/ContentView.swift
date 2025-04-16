//
//  ContentView.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 16.04.2025.
//

import SwiftUI

class JSONViewModel: ObservableObject {
    @Published var formattedText: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchJSON(from fileName: String) {
        guard let url = URL(string: "http://c910-188-25-128-207.ngrok-free.app/files/\(fileName)") else {
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
                    let matches = JSONMatchParser.parseMatches(from: data, league: fileName)

                    let formatter = MatchFormatter()
                    self.formattedText = matches.map { formatter.format(match: $0) }.joined(separator: "\n\n")
                } catch {
                    self.errorMessage = "Failed to parse JSON"
                }
            }
        }.resume()
    }
}

struct ContentView: View {
    var body: some View {
        FileListView()
    }
}

#Preview {
    ContentView()
}

import Foundation

struct Match: Identifiable {
    let id = UUID()
    let league: String
    let team1: String
    let team2: String
    let odds: [String: Double]
    let commenceTime: String
    let predictability: Double
    let action: String
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
                commenceTime: commenceTime,
                predictability: abs(best1-best2),
                action: abs(best1-best2) < 1.0 ? "PARIUS SIGUR" : "PARIU RISCANT"
            )

            matches.append(match)
        }

        return matches
    }
}

class MatchFormatter {
    func format(match: Match) -> String {
        let totalWidth = 44
        let border = "+" + String(repeating: "-", count: totalWidth - 2) + "+"

        let dateStr: String
        if let date = ISO8601DateFormatter().date(from: match.commenceTime) {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy HH:mm"
            dateStr = formatter.string(from: date)
        } else {
            dateStr = match.commenceTime
        }

        func center(_ text: String) -> String {
            let trimmed = text.count > (totalWidth - 2) ? String(text.prefix(totalWidth - 5)) + "..." : text
            let padding = max(0, (totalWidth - 2 - trimmed.count) / 2)
            let line = String(repeating: " ", count: padding) + trimmed
            return "|" + line.padding(toLength: totalWidth - 2, withPad: " ", startingAt: 0) + "|"
        }

        let lines = [
            center(match.league),
            center("\(match.team1) vs \(match.team2)"),
            center(dateStr),
            center(String(format: "%.2f", match.predictability)),
            center(match.action)
        ]

        return ([border] + lines + [border]).joined(separator: "\n")
    }
}

import SwiftUI

struct FileListView: View {
    @State private var files: [String] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading files...")
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else {
                    List(files, id: \.self) { file in
                        NavigationLink(destination: FileDetailView(fileName: file)) {
                            Text(file)
                                .font(.system(size: 14, design: .monospaced))
                                .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Available Files")
            .onAppear(perform: fetchFileList)
        }
    }

    func fetchFileList() {
        guard let url = URL(string: "http://c910-188-25-128-207.ngrok-free.app/files") else {
            self.errorMessage = "Invalid URL"
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let data = data, let html = String(data: data, encoding: .utf8) else {
                    self.errorMessage = "Failed to load data"
                    return
                }

                // Extract .json filenames from HTML anchor tags
                let matches = html.matches(for: ">([^\\\"]+\\.json)<")
                self.files = matches
            }
        }

        task.resume()
    }
}

extension String {
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = self as NSString
            let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range(at: 1)) }
        } catch {
            print("Regex error: \(error)")
            return []
        }
    }
}

struct FileDetailView: View {
    let fileName: String
    @StateObject private var viewModel = JSONViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            if let content = viewModel.formattedText {
                ScrollView {
                    Text(content)
                        .font(.system(size: 12, design: .monospaced))
                        .padding()
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
        .navigationTitle(fileName)
        .onAppear {
            viewModel.fetchJSON(from: fileName)
        }
    }
}
