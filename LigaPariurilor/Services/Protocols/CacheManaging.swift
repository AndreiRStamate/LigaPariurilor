//
//  CacheManaging.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 19.04.2025.
//

import Foundation

/// Saves and retrieves Data blobs to disk
protocol CacheManaging {
    static func load(fileName: String, expiry: TimeInterval?) -> Data?
    static func save(_ data: Data, fileName: String, updateMeta: Bool)
}
