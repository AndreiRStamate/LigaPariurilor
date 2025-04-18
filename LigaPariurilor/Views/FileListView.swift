//
//  FileListView.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import SwiftUI

struct FileListView: View {
    @State private var leagueFiles: [LeagueFile] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var searchText: String = ""
    @State private var refreshFlag = UUID()
    @State private var refreshingFile: String? = nil
    @State private var showToast: Bool = false
    @AppStorage("showFavoritesOnly") private var showFavoritesOnly: Bool = false
    @State private var favoriteFileNames: Set<String> = FileListView.loadFavoriteFileNames()

    func isStale(fileName: String) -> Bool {
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
    

    var body: some View {
        TabView {
            mainFileListPage
                .tabItem {
                    Label("Fișiere", systemImage: "doc.text")
                }

            MockPageView1()
                .tabItem {
                    Label("Mock 1", systemImage: "1.circle")
                }

            MockPageView2()
                .tabItem {
                    Label("Mock 2", systemImage: "2.circle")
                }
        }
    }
    
    private var mainFileListPage: some View {
        NavigationView {
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search", text: $searchText)
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)

                Toggle("Favorites Only", isOn: $showFavoritesOnly)
                    .padding(.horizontal)

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
                    List {
                        ForEach(groupedAndSortedFiles, id: \.key) { region, items in
                            Section(header: Text(region)) {
                                ForEach(items) { file in
                                    Group {
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
                                            Group {
                                                if refreshingFile == file.fileName {
                                                    ProgressView()
                                                        .scaleEffect(0.6)
                                                } else if isStale(fileName: file.fileName) {
                                                    Image(systemName: "arrow.clockwise.circle")
                                                        .foregroundColor(.orange)
                                                        .onTapGesture {
                                                            refreshingFile = file.fileName
                                                            fetchAndCacheFile(file.fileName)
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
                                                        FileListView.toggleFavorite(file.fileName)
                                                        favoriteFileNames = FileListView.loadFavoriteFileNames()
                                                    }
                                                    .padding(.leading, 8)
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                    }
                                    .id(refreshFlag)
                                }
                            }
                        }
                    }
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
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Ligi Disponibile")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                }
            }
            .onAppear(perform: fetchFileList)
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
    
    /// Groups filtered files by region and sorts sections by size
    private var groupedAndSortedFiles: [(key: String, value: [LeagueFile])] {
        let grouped = Dictionary(grouping: filteredFiles, by: { $0.region })
        return grouped.sorted { $0.value.count > $1.value.count }
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

    private static func loadFavoriteFileNames() -> Set<String> {
        let saved = UserDefaults.standard.stringArray(forKey: "favoriteFileNames") ?? []
        return Set(saved)
    }

    private static func saveFavoriteFileNames(_ names: Set<String>) {
        UserDefaults.standard.set(Array(names), forKey: "favoriteFileNames")
    }

    private static func toggleFavorite(_ fileName: String) {
        var names = loadFavoriteFileNames()
        if names.contains(fileName) {
            names.remove(fileName)
        } else {
            names.insert(fileName)
        }
        saveFavoriteFileNames(names)
    }

}

struct MockPageView1: View {
    var body: some View {
        ZStack {
            Color.orange.opacity(0.2).ignoresSafeArea()
            Text("Mock Page 1")
                .font(.largeTitle)
                .bold()
        }
    }
}

struct MockPageView2: View {
    var body: some View {
        ZStack {
            Color.green.opacity(0.2).ignoresSafeArea()
            Text("Mock Page 2")
                .font(.largeTitle)
                .bold()
        }
    }
}
