//
//  MatchBetsViewModel.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 22.04.2025.
//

import Foundation

final class MatchBetsViewModel: ObservableObject {
    let match: Match
    @Published var bet: Bet?
    
    init(match: Match) {
        self.match = match
        self.bet = Bet.loadFromFile(match: match.matchId) ?? Bet(matchString: match.matchId, events: [])
    }
    
    func displayName() -> String {
        return "\(match.team1) \nvs \(match.team2)"
    }
}
