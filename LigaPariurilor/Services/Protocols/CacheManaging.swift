//
//  CacheManaging.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 19.04.2025.
//

import Foundation

/// Saves and retrieves Data blobs to disk
protocol CacheManaging {
  func load(fileName: String) -> Data?
  func save(_ data: Data, fileName: String)
}
