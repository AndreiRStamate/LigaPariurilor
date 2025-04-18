//
//  FootballListPage.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 18.04.2025.
//

import SwiftUI

struct FootballListPage: View {
    @State private var leagueFiles: [LeagueFile] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var searchText: String = ""
    @State private var refreshFlag = UUID()
    @State private var refreshingFile: String? = nil
    @State private var showToast: Bool = false
    @AppStorage("showFavoritesOnly") private var showFavoritesOnly: Bool = false
    @State private var favoriteFileNames: Set<String> = loadFavoriteFileNames()
    @State private var showingSettings = false
    /// User-editable analysis template
    @AppStorage("analysisFootballTemplate") private var analysisFootballTemplate: String = Match.defaultFootballAnalysisTemplate

    var body: some View {
        NavigationView {
            VStack {
                searchBar
                toggleView
                contentView
                toastView
            }
            .padding(.top, 20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Ligi Disponibile")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings.toggle()
                    }) {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                NavigationView {
                    Form {
                        Section(header: Text("Șablon prompt").font(.subheadline)) {
                            TextEditor(text: $analysisFootballTemplate)
                                .font(.callout)
                                .frame(minHeight: 200)
                        }
                        Section(header: Text("Cuvinte cheie").font(.subheadline)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("{team1} – Echipa gazdă")
                                Text("{team2} – Echipa oaspete")
                                Text("{league} – Competiție/Ligă")
                                Text("{commenceTime} – Dată și oră")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        Section {
                            Button("Revino la prompt-ul inițial") {
                                analysisFootballTemplate = Match.defaultFootballAnalysisTemplate
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .navigationTitle("Editare prompt")
                    .navigationBarItems(trailing: Button("Gata") {
                        showingSettings = false
                    })
                }
            }
            .onAppear(perform: fetchFileList)
        }
    }

    @ViewBuilder
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search", text: $searchText)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    @ViewBuilder
    private var toggleView: some View {
        Toggle("Favorite", isOn: $showFavoritesOnly)
            .padding(.horizontal)
    }

    @ViewBuilder
    private var contentView: some View {
        if isLoading {
            ProgressView("Loading files...")
        } else if let message = errorMessage {
            VStack(spacing: 12) {
                Text("Eroare: \(message)")
                    .foregroundColor(.red)
                Button("Reîncarcă") {
                    errorMessage = nil
                    isLoading = true
                    fetchFileList()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        } else {
            List {
                ForEach(groupedAndSortedFiles, id: \.key) { section in
                    Section(header: Text(section.key)) {
                        ForEach(section.value) { file in
                            NavigationLink(destination: FileDetailView(fileName: file.fileName, url: APIConfig.footballURL, sportsType: "football")) {
                                FootballFileRow(
                                    file: file,
                                    refreshingFile: $refreshingFile,
                                    favoriteFileNames: $favoriteFileNames,
                                    refreshFlag: $refreshFlag,
                                    showToast: $showToast
                                )
                            }
                            .id(refreshFlag)
                        }
                    }
                }
            }
            .animation(.easeInOut, value: showFavoritesOnly)
            .refreshable {
                fetchFileListWithoutCache()
            }
        }
    }

    @ViewBuilder
    private var toastView: some View {
        if showToast {
            Text("Datele au fost actualizate.")
                .font(.caption)
                .padding(8)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.bottom, 16)
                .transition(.opacity)
        }
    }

    private var cachedFileNames: Set<String> {
        Set(loadCachedFiles().map { $0.fileName })
    }
    
    var filteredFiles: [LeagueFile] {
        // Apply search filter first
        let base = searchText.isEmpty
            ? leagueFiles
            : leagueFiles.filter { $0.displayName.localizedCaseInsensitiveContains(searchText) }
        // Then apply favorites filter if enabled
        if showFavoritesOnly {
            return base.filter { favoriteFileNames.contains($0.fileName) }
        }
        return base
    }
    
    /// Groups filtered files by region and sorts sections by size, with stable ordering
    private var groupedAndSortedFiles: [(key: String, value: [LeagueFile])] {
        let grouped = Dictionary(grouping: filteredFiles, by: \.region)
        return grouped
            .map { region, files in
                let sortedFiles = files.sorted { $0.displayName < $1.displayName }
                return (key: region, value: sortedFiles)
            }
            .sorted { first, second in
                if first.value.count != second.value.count {
                    return first.value.count > second.value.count
                }
                return first.key < second.key
            }
    }

    func fetchFileList() {
        let cachedFileNames = self.loadFileListFromCache()
        if !cachedFileNames.isEmpty {
            self.populateLeagueFiles(from: cachedFileNames)
            self.isLoading = false
            return
        }

        let task = URLSession.shared.dataTask(with: APIConfig.footballURL) { data, response, error in
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

                let matches = html.matches(for: ">([^\\\"]+\\.json)<")
                self.saveFileListToCache(matches)
                self.populateLeagueFiles(from: matches)
                for file in matches {
                    if loadFromCache(fileName: file) == nil {
                        fetchAndCacheFile(file, url: APIConfig.footballURL)
                    }
                }
            }
        }

        task.resume()
    }

    private func fetchFileListWithoutCache() {
        self.isLoading = true

        let task = URLSession.shared.dataTask(with: APIConfig.footballURL) { data, response, error in
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

                let matches = html.matches(for: ">([^\\\"]+\\.json)<")
                self.saveFileListToCache(matches)
                self.populateLeagueFiles(from: matches)
                for file in matches {
                    if loadFromCache(fileName: file) == nil {
                        fetchAndCacheFile(file, url: APIConfig.footballURL)
                    }
                }
            }
        }

        task.resume()
    }

    func fileListCacheURL() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("file_list_football_cache.txt")
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
        let mappedFiles = matches.map { file in
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
        self.leagueFiles = sortedFiles
    }

    fileprivate static func loadFavoriteFileNames() -> Set<String> {
        let saved = UserDefaults.standard.stringArray(forKey: "favoriteFileNames") ?? []
        return Set(saved)
    }

    private static func saveFavoriteFileNames(_ names: Set<String>) {
        UserDefaults.standard.set(Array(names), forKey: "favoriteFileNames")
    }

    fileprivate static func toggleFavorite(_ fileName: String) {
        var names = loadFavoriteFileNames()
        if names.contains(fileName) {
            names.remove(fileName)
        } else {
            names.insert(fileName)
        }
        saveFavoriteFileNames(names)
    }
}

struct FootballFileRow: View {
    let file: LeagueFile
    @Binding var refreshingFile: String?
    @Binding var favoriteFileNames: Set<String>
    @Binding var refreshFlag: UUID
    @Binding var showToast: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(file.displayName.uppercased())
                    .font(.system(size: 14, design: .monospaced))
                Text(file.fileName
                        .replacingOccurrences(of: "api_response_", with: "")
                        .replacingOccurrences(of: ".json", with: ""))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            if refreshingFile == file.fileName {
                ProgressView()
                    .scaleEffect(0.6)
            } else if isStale(fileName: file.fileName) {
                Image(systemName: "arrow.clockwise.circle")
                    .foregroundColor(.orange)
                    .onTapGesture {
                        refreshingFile = file.fileName
                        fetchAndCacheFile(file.fileName, url: APIConfig.footballURL)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            refreshingFile = nil
                            refreshFlag = UUID()
                            showToast = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showToast = false
                            }
                        }
                    }
            }
            Image(systemName: favoriteFileNames.contains(file.fileName) ? "star.fill" : "star")
                .foregroundColor(.yellow)
                .onTapGesture {
                    FootballListPage.toggleFavorite(file.fileName)
                    favoriteFileNames = FootballListPage.loadFavoriteFileNames()
                }
                .padding(.leading, 8)
        }
        .padding(.vertical, 4)
    }
}
