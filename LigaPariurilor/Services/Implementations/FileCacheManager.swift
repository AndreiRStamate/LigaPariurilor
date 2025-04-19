//
//  FileCacheManager.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 19.04.2025.
//

import Foundation

class FileCacheManager: CacheManaging {
  private let folder: URL

  init(documentDirectory: URL = FileManager.default
         .urls(for: .documentDirectory, in: .userDomainMask).first!) {
    self.folder = documentDirectory
  }

  func load(fileName: String) -> Data? {
    let url = folder.appendingPathComponent(fileName)
    return FileManager.default.fileExists(atPath: url.path)
      ? try? Data(contentsOf: url)
      : nil
  }

  func save(_ data: Data, fileName: String) {
    let url = folder.appendingPathComponent(fileName)
    try? data.write(to: url)
  }
}
