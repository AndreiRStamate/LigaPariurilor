//
//  ContentView.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 16.04.2025.
//

import SwiftUI
// Central API configuration
struct APIConfig {
    static let baseURL = "http://a6ae-188-25-128-207.ngrok-free.app"
}

class JSONViewModel: ObservableObject {
    @Published var matches: [Match] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @AppStorage("sortMode") var sortMode: SortMode = .predictability
    @Published private var allMatches: [Match] = []

    enum SortMode: String {
        case commenceTime
        case predictability
    }
    
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

struct MatchBoxView: View {
    let match: Match

    private func formattedDate(_ isoString: String) -> String {
        if let date = ISO8601DateFormatter().date(from: isoString) {
            let calendar = Calendar.current
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            if calendar.isDateInToday(date) {
                return "Azi la \(timeFormatter.string(from: date))"
            } else if calendar.isDateInTomorrow(date) {
                return "Mâine la \(timeFormatter.string(from: date))"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyyy HH:mm"
                return formatter.string(from: date)
            }
        }
        return isoString
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LEAGUE_NAMES[match.league] ?? match.league)
                .font(.headline)
            Text("\(match.team1) vs \(match.team2)")
                .font(.subheadline)
            Text(formattedDate(match.commenceTime))
                .font(.caption)
            HStack {
                Text(String(format: "Predictabilitate: %.2f", match.predictability))
                    .font(.caption2)
                Spacer()
                Text(match.action)
                    .font(.caption2)
                    .foregroundColor(match.predictability < 1.0 ? .green : .red)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
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
                predictability: abs(best1-best2),
                action: abs(best1-best2) < 1.0 ? "PARIUS SIGUR" : "PARIU RISCANT"
            )

            matches.append(match)
        }

        return matches
    }
}

let LEAGUE_NAMES: [String: String] = [
    "soccer_argentina_primera_division": "Argentina Primera Division",
    "soccer_australia_aleague": "Australia A-League",
    "soccer_austria_bundesliga": "Austria Bundesliga",
    "soccer_belgium_first_div": "Belgium First Division",
    "soccer_brazil_campeonato": "Brazil Campeonato",
    "soccer_brazil_serie_b": "Brazil Serie B",
    "soccer_chile_campeonato": "Chile Campeonato",
    "soccer_china_superleague": "China Super League",
    "soccer_conmebol_copa_libertadores": "CONMEBOL Copa Libertadores",
    "soccer_conmebol_copa_sudamericana": "CONMEBOL Copa Sudamericana",
    "soccer_denmark_superliga": "Denmark Superliga",
    "soccer_efl_champ": "EFL Championship",
    "soccer_england_league1": "England League One",
    "soccer_england_league2": "England League Two",
    "soccer_epl": "English Premier League",
    "soccer_fa_cup": "FA Cup",
    "soccer_finland_veikkausliiga": "Finland Veikkausliiga",
    "soccer_france_ligue_one": "France Ligue 1",
    "soccer_france_ligue_two": "France Ligue 2",
    "soccer_germany_bundesliga": "Germany Bundesliga",
    "soccer_germany_bundesliga2": "Germany Bundesliga 2",
    "soccer_germany_liga3": "Germany Liga 3",
    "soccer_greece_super_league": "Greece Super League",
    "soccer_italy_serie_a": "Italy Serie A",
    "soccer_italy_serie_b": "Italy Serie B",
    "soccer_japan_j_league": "Japan J-League",
    "soccer_korea_kleague1": "Korea K-League 1",
    "soccer_league_of_ireland": "League of Ireland",
    "soccer_mexico_ligamx": "Mexico Liga MX",
    "soccer_netherlands_eredivisie": "Netherlands Eredivisie",
    "soccer_norway_eliteserien": "Norway Eliteserien",
    "soccer_poland_ekstraklasa": "Poland Ekstraklasa",
    "soccer_portugal_primeira_liga": "Portugal Primeira Liga",
    "soccer_spain_la_liga": "La Liga",
    "soccer_spain_segunda_division": "Spain Segunda Division",
    "soccer_sweden_allsvenskan": "Sweden Allsvenskan",
    "soccer_sweden_superettan": "Sweden Superettan",
    "soccer_switzerland_superleague": "Switzerland Super League",
    "soccer_turkey_super_league": "Turkey Super League",
    "soccer_uefa_champs_league": "UEFA Champions League",
    "soccer_uefa_champs_league_women": "UEFA Champions League Women",
    "soccer_uefa_europa_conference_league": "UEFA Europa Conference League",
    "soccer_uefa_europa_league": "UEFA Europa League",
    "soccer_uefa_nations_league": "UEFA Nations League",
    "soccer_usa_mls": "USA Major League Soccer"
]

class MatchFormatter {
    func format(match: Match) -> String {
        let totalWidth = 44
        let border = "+" + String(repeating: "-", count: totalWidth - 2) + "+"

        let dateStr: String
        if let date = ISO8601DateFormatter().date(from: match.commenceTime) {
            let calendar = Calendar.current
            if calendar.isDateInToday(date) {
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                dateStr = "Azi la \(timeFormatter.string(from: date))"
            } else if calendar.isDateInTomorrow(date) {
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                dateStr = "Mâine la \(timeFormatter.string(from: date))"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyyy HH:mm"
                dateStr = formatter.string(from: date)
            }
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
            center(LEAGUE_NAMES[match.league] ?? match.league),
            center("\(match.team1) vs \(match.team2)"),
            center(dateStr),
            center(String(format: "%.2f", match.predictability)),
            center(match.action)
        ]

        return ([border] + lines + [border]).joined(separator: "\n")
    }
}

import SwiftUI

struct LeagueFile: Identifiable {
    let id = UUID()
    let fileName: String
    let leagueKey: String
    let displayName: String
    let region: String
}

struct FileListView: View {
    @State private var leagueFiles: [LeagueFile] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var searchText: String = ""
    

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading files...")
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 12) {
                        Text("Eroare: \(errorMessage)")
                            .foregroundColor(.red)
                        Button("Reîncarcă") {
                            self.errorMessage = nil
                            self.isLoading = true
                            self.fetchFileList()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    // Offline banner removed
                    
                    List {
                        ForEach(Dictionary(grouping: filteredFiles, by: { $0.region })
                            .sorted(by: { $0.value.count > $1.value.count }), id: \.key) { region, items in
                            Section(header: Text(region)) {
                                ForEach(items) { file in
                                    NavigationLink(destination: FileDetailView(fileName: file.fileName)) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(file.displayName.uppercased())
                                                    .font(.system(size: 14, design: .monospaced))
                                                Text(file.fileName.replacingOccurrences(of: "api_response_", with: "").replacingOccurrences(of: ".json", with: ""))
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            if cachedFileNames.contains(file.fileName) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Ligi Disponibile")
                        .font(.headline)
                }
            }
            .onAppear(perform: fetchFileList)
        }
    }
    private var cachedFileNames: Set<String> {
        Set(loadCachedFiles().map { $0.fileName })
    }
    func fetchFileList() {
        guard let url = URL(string: "\(APIConfig.baseURL)/files") else {
            self.errorMessage = "Invalid URL"
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    let cachedFileNames = self.loadFileListFromCache()
                    if cachedFileNames.isEmpty {
                        let cached = loadCachedFiles()
                        if cached.isEmpty {
                            self.errorMessage = error.localizedDescription
                        } else {
                            self.leagueFiles = cached
                        }
                    } else {
                        self.populateLeagueFiles(from: cachedFileNames)
                    }
                    return
                }

                guard let data = data, let html = String(data: data, encoding: .utf8) else {
                    self.errorMessage = "Failed to load data"
                    return
                }

                let matches = html.matches(for: ">([^\\\"]+\\.json)<")
                self.saveFileListToCache(matches)
            self.populateLeagueFiles(from: matches)
            for file in matches {
                if loadFromCache(fileName: file) == nil {
                    fetchAndCacheFile(file)
                }
            }
            }
        }

        task.resume()
    }

    var filteredFiles: [LeagueFile] {
        if searchText.isEmpty {
            return leagueFiles
        } else {
            return leagueFiles.filter { $0.displayName.localizedCaseInsensitiveContains(searchText) }
        }
    }

    func fileListCacheURL() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("file_list_cache.txt")
    }

    func saveFileListToCache(_ files: [String]) {
        guard let url = fileListCacheURL() else { return }
        let text = files.joined(separator: "\n")
        try? text.write(to: url, atomically: true, encoding: .utf8)
    }

    func loadFileListFromCache() -> [String] {
    guard let url = fileListCacheURL(),
          let content = try? String(contentsOf: url, encoding: .utf8) else { return [] }
        return content.components(separatedBy: "\n")
    }

    func populateLeagueFiles(from matches: [String]) {
        self.leagueFiles = matches.map { file in
            let trimmed = file
                .replacingOccurrences(of: "api_response_", with: "")
                .replacingOccurrences(of: ".json", with: "")
            let displayName = LEAGUE_NAMES[trimmed] ?? trimmed
            let region = regionFromLeagueKey(trimmed)
            return LeagueFile(fileName: file, leagueKey: trimmed, displayName: displayName, region: region)
        }.sorted { $0.region < $1.region || ($0.region == $1.region && $0.displayName < $1.displayName) }
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
        VStack(alignment: .leading, spacing: 0) {
            Picker("Sort by", selection: $viewModel.sortMode) {
                Text("Evaluare").tag(JSONViewModel.SortMode.predictability)
                Text("Dată").tag(JSONViewModel.SortMode.commenceTime)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.top)
            .onChange(of: viewModel.sortMode) {
                viewModel.sortMatches()
            }

            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity)
                Spacer()
            } else if let error = viewModel.errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Text("Eroare: \(error)")
                        .foregroundColor(.red)
                    Button("Încearcă din nou") {
                        viewModel.fetchJSON(from: fileName)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else if !viewModel.matches.isEmpty {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.matches) { match in
                            MatchBoxView(match: match)
                        }
                    }
                    .padding()
                }
            } else {
                Spacer()
                Text("Niciun meci găsit.")
                    .frame(maxWidth: .infinity)
                Spacer()
            }
        }
        .padding(.bottom)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text({
                    let trimmed = fileName
                        .replacingOccurrences(of: "api_response_", with: "")
                        .replacingOccurrences(of: ".json", with: "")
                    return (LEAGUE_NAMES[trimmed] ?? trimmed).uppercased()
                }())
                .font(.system(size: 14, weight: .semibold, design: .default))
            }
        }
        .onAppear {
            viewModel.fetchJSON(from: fileName)
        }
    }
}

func loadCachedFiles() -> [LeagueFile] {
    let fileManager = FileManager.default
    guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return []
    }

    do {
        let files = try fileManager.contentsOfDirectory(atPath: directory.path)
            .filter { $0.hasSuffix(".json") }
            .map { file in
                let trimmed = file
                    .replacingOccurrences(of: "api_response_", with: "")
                    .replacingOccurrences(of: ".json", with: "")
                let displayName = LEAGUE_NAMES[trimmed] ?? trimmed
                let region = regionFromLeagueKey(trimmed)
                return LeagueFile(fileName: file, leagueKey: trimmed, displayName: displayName, region: region)
            }
        return files.sorted { $0.region < $1.region || ($0.region == $1.region && $0.displayName < $1.displayName) }
    } catch {
        print("Error reading cached files: \(error)")
        return []
    }
}

func regionFromLeagueKey(_ key: String) -> String {
    if key.contains("uefa") || key.contains("england") || key.contains("denmark") || key.contains("epl") || key.contains("finland") || key.contains("france") || key.contains("germany") || key.contains("spain") || key.contains("italy") || key.contains("portugal") || key.contains("netherlands") || key.contains("sweden") || key.contains("austria") || key.contains("belgium") || key.contains("switzerland") || key.contains("norway") || key.contains("poland") || key.contains("greece") || key.contains("ireland") || key.contains("scotland") || key.contains("turkey") || key.contains("fa_cup") || key.contains("efl_champ") {
        return "🇪🇺 Europa"
    } else if key.contains("brazil") || key.contains("argentina") || key.contains("mexico") || key.contains("chile") || key.contains("conmebol") {
        return "🌎 America de Sud"
    } else if key.contains("japan") || key.contains("korea") || key.contains("china") {
        return "🌏 Asia"
    } else if key.contains("usa") {
        return "🇺🇸 America de Nord"
    } else if key.contains("australia") {
        return "🇦🇺 Oceania"
    }
    return "🌐 Alta"
}

    func fetchAndCacheFile(_ fileName: String) {
        guard let url = URL(string: "\(APIConfig.baseURL)/files/\(fileName)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                saveToCache(data, fileName: fileName)
            }
        }.resume()
    }
    
    func saveToCache(_ data: Data, fileName: String) {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
                .appendingPathComponent(fileName) else { return }
        try? data.write(to: url)
    }
    
    func loadFromCache(fileName: String) -> Data? {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
                .appendingPathComponent(fileName),
              FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try? Data(contentsOf: url)
    }
