//
//  JSONFetching.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 19.04.2025.
//

import Foundation

/// Fetches raw Data for a given resource name or URL
protocol JSONFetching {
  func fetch(fileName: String,
             from baseURL: URL,
             completion: @escaping (Result<Data, Error>) -> Void)
}
