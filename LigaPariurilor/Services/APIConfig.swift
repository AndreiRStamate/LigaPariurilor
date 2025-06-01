//
//  APIConfig.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import Foundation

struct APIConfig {
    private static let baseURL = URL(string: "https://1176-86-127-221-162.ngrok-free.app")!
    
    /// Returns the endpoint URL for the given sport.
    static func url(for sportType: SportType) -> URL {
        return URL(string: "\(APIConfig.baseURL)/\(sportType.rawValue)")!
    }
    static func urlip() -> URL {
        return URL(string: "\(APIConfig.baseURL)/ip")!
    }
}
