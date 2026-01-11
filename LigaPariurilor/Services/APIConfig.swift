//
//  APIConfig.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import Foundation

struct APIConfig {
    private static let baseURL = URL(string: "https://small-artifactory.fly.dev")!
    
    /// Returns the endpoint URL for the given sport.
    static func url(for sportType: SportType) -> URL {
        return URL(string: "\(APIConfig.baseURL)/\(sportType.rawValue)")!
    }
}
