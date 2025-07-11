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
    case cricket
    // Add other sports as needed
}

final class SportListViewModel: ObservableObject {
    let sportType: SportType

    init(sportType: SportType) {
        self.sportType = sportType
        let defaultsKey = "favoriteFileNames_\(sportType.rawValue)"
        self.favoriteFileNames = Set(
            UserDefaults.standard.stringArray(forKey: defaultsKey) ?? []
        )
    }

    @Published var leagueFiles: [LeagueFile] = []
    @Published var isLoading = true
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    @Published var refreshingFile: String? = nil
    @Published var showToast: Bool = false
    @Published var favoriteFileNames: Set<String>
    @Published var showFavoritesOnly: Bool = UserDefaults.standard.bool(forKey: "showFavoritesOnly") {
        didSet {
            UserDefaults.standard.set(showFavoritesOnly, forKey: "showFavoritesOnly")
        }
    }
    @Published var showFutureOnly: Bool = UserDefaults.standard.bool(forKey: "showFutureOnly") {
        didSet {
            UserDefaults.standard.set(showFutureOnly, forKey: "showFutureOnly")
        }
    }
    
    private var cacheFileName: String {
        "file_list_\(sportType.rawValue)_cache.txt"
    }
    
    private var favoritesKey: String {
        "favoriteFileNames_\(sportType.rawValue)"
    }
    
    private var cachedFileNames: Set<String> {
        Set(CacheService.loadCachedFiles().map { $0.fileName })
    }
    
    var filteredFiles: [LeagueFile] {
        var result = searchText.isEmpty
            ? leagueFiles
            : leagueFiles.filter { $0.displayName.localizedCaseInsensitiveContains(searchText) }

        if showFavoritesOnly {
            result = result.filter { favoriteFileNames.contains($0.fileName) }
        }

        if showFutureOnly {
            result = result.filter { hasFutureGames(fileName: $0.fileName) }
        }

        return result
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

    private func prepareForCaching(_ matches: [String]) -> Data? {
        matches
            .joined(separator: "\n")
            .data(using: .utf8)
    }

    func fetchFileList(useCache: Bool = true, withForce: Bool = false) {
        if useCache {
            let cachedFileNames = CacheService.load(fileName: self.cacheFileName, expiry: nil)
                .flatMap { String(data: $0, encoding: .utf8) }?
                .components(separatedBy: "\n") ?? []
            if !cachedFileNames.isEmpty {
                self.populateLeagueFiles(from: cachedFileNames)
                self.isLoading = false
                return
            }
        }

        self.isLoading = true

        let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String
        var request = URLRequest(url: APIConfig.url(for: sportType))
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
                self.prepareForCaching(matches).map {
                    CacheService.save($0, fileName: self.cacheFileName, updateMeta: false)
                }
                self.populateLeagueFiles(from: matches)
                for file in matches {
                    if CacheService.load(fileName: file, expiry: CacheService.fullCacheExpiry) == nil  || withForce == true{
                        CacheService.fetchAndCacheFile(file, url: APIConfig.url(for: self.sportType))
                    }
                }
            }
        }

        task.resume()
    }

    func populateLeagueFiles(from matches: [String]) {
        let mappedFiles = matches.map { file in
            let trimmed = file.trimmedFilename
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

    func toggleFavorite(fileName: String) {
        var names = favoriteFileNames
        if names.contains(fileName) {
            names.remove(fileName)
        } else {
            names.insert(fileName)
        }
        favoriteFileNames = names
        UserDefaults.standard.set(Array(names), forKey: favoritesKey)
    }
    
    func refresh(fileName: String, completion: @escaping () -> Void) {
        refreshingFile = fileName
        CacheService.fetchAndCacheFile(fileName, url: APIConfig.url(for: sportType))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshingFile = nil
            completion()
            self.showToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showToast = false
            }
        }
    }

    /// Returns `true` if the cached JSON for `fileName` contains at least one match whose
    /// `commence_time` is in the future.
    private func hasFutureGames(fileName: String) -> Bool {
        guard let data = CacheService.load(fileName: fileName,
                                           expiry: CacheService.fullCacheExpiry) else {
            return false
        }
        
        let decoder = JSONMatchDecoder()
        if let matches = try? decoder.decode(data) {
            return matches.contains { $0.commenceTime > Date().ISO8601Format() }
        }
        
        
        return false
    }

    /// Determines if a file is stale (uses existing standalone isStale function)
    func isStale(fileName: String) -> Bool {
        return CacheService.isStale(fileName: fileName)
    }

    func fetchIP(completion: @escaping (String?) -> Void) {
        let url = APIConfig.urlip()
        var request = URLRequest(url: url)
        let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching IP: \(error)")
                    completion(nil)
                    return
                }
                guard let data = data, let ipString = String(data: data, encoding: .utf8) else {
                    print("Invalid IP data")
                    completion(nil)
                    return
                }
                completion(ipString)
            }
        }
        task.resume()
    }
}
