//
//  APIConfig.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import Foundation

struct APIConfig {
    private static let baseURL = URL(string: "https://f531-188-25-128-207.ngrok-free.app")!
    static let footballURL = URL(string: "\(APIConfig.baseURL)/football")!
    static let basketballURL = URL(string: "\(APIConfig.baseURL)/basketball")!
}
