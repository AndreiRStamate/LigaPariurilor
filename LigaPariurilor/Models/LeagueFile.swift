//
//  LeagueFile.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import Foundation

struct LeagueFile: Identifiable {
    let id = UUID()
    let fileName: String
    let leagueKey: String
    let displayName: String
    let region: String
}
