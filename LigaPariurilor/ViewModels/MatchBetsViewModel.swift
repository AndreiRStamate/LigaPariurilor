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
        self.bet = Bet.loadFromFile(match: match.matchId) ?? Bet(matchString: match.matchId, events: MatchBetsViewModel.defaultEvents)
    }
    
    func displayName() -> String {
        return "\(match.team1) \nvs \(match.team2)"
    }
    
    func addEvent(_ event: BetEvent) {
        if let index = bet?.events.firstIndex(where: { $0.name == event.name }) {
            bet?.events[index] = event
        } else {
            bet?.events.append(event)
        }
        bet?.saveToFile()
    }

    func deleteEvent(_ event: BetEvent) {
        if let index = bet?.events.firstIndex(where: { $0.id == event.id }) {
            bet?.events.remove(at: index)
            bet?.saveToFile()
        }
    }
    
    static let defaultEvents: [BetEvent] = [
        BetEvent.bttsYes(),
        BetEvent.totalGoals(over: 3.5),
        BetEvent.totalCorners(over: 1.5),
        BetEvent.totalCards(under: 2),
        BetEvent.correctScore("2:1"),
        BetEvent.chance(BetSelection.Chance3Option.home),
        BetEvent.doubleChance(BetSelection.DoubleChanceOption.homeOrDraw)
    ]
}
