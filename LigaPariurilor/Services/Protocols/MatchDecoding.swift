//
//  MatchDecoding.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 19.04.2025.
//

import Foundation

/// Decodes raw Data into your model objects
protocol MatchDecoding {
  func decode(_ data: Data) throws -> [Match]
}
