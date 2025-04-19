//
//  URLSessionJSONFetcher.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 19.04.2025.
//

import Foundation
enum FetchError: Error {
    case noData
}

class URLSessionJSONFetcher: JSONFetching {
  func fetch(fileName: String,
             from baseURL: URL,
             completion: @escaping (Result<Data, Error>) -> Void) {
    let url = baseURL.appendingPathComponent(fileName)
    URLSession.shared.dataTask(with: url) { data, _, error in
      if let e = error { return completion(.failure(e)) }
      guard let d = data else { return completion(.failure(FetchError.noData)) }
      completion(.success(d))
    }
    .resume()
  }
}
