//
//  SportListViewModel.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 19.04.2025.
//

import Foundation

enum SportType: String {
    case football
    case basketball
    case hockey
    // Add other sports as needed
}

final class SportListViewModel: ObservableObject {
    let sportType: SportType

    init(sportType: SportType) {
        self.sportType = sportType
    }

    @Published var leagueFiles: [LeagueFile] = []
    @Published var isLoading = true
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    @Published var refreshingFile: String? = nil
    @Published var showToast: Bool = false
    @Published var favoriteFileNames: Set<String> = loadFavoriteFileNames()
    @Published var showFavoritesOnly: Bool = UserDefaults.standard.bool(forKey: "showFavoritesOnly") {
        didSet {
            UserDefaults.standard.set(showFavoritesOnly, forKey: "showFavoritesOnly")
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
    var groupedAndSortedFiles: [(key: String, value: [LeagueFile])] {
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

    func fetchFileListWithoutCache() {
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

    static func loadFavoriteFileNames() -> Set<String> {
        let saved = UserDefaults.standard.stringArray(forKey: "favoriteFileNames") ?? []
        return Set(saved)
    }

    static private func saveFavoriteFileNames(_ names: Set<String>) {
        UserDefaults.standard.set(Array(names), forKey: "favoriteFileNames")
    }

    static func toggleFavorite(_ fileName: String) {
        var names = loadFavoriteFileNames()
        if names.contains(fileName) {
            names.remove(fileName)
        } else {
            names.insert(fileName)
        }
        saveFavoriteFileNames(names)
    }
}
