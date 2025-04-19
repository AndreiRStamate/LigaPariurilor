//
//  JSONMatchDecoder.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 19.04.2025.
//

import Foundation

class JSONMatchDecoder: MatchDecoding {
  func decode(_ data: Data) throws -> [Match] {
    return JSONMatchParser.parseMatches(from: data)
  }
}
