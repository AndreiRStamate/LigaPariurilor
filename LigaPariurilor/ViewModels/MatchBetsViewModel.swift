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
    
    @Published var selectedType: BetType = .yesOrNo
    @Published var selectedName: BetEventName = .btts
    @Published var boolValue: Bool = false
    @Published var bound: BetSelection.Bound = .over
    @Published var value: Double = 2.5
    @Published var chanceOption: BetSelection.Chance3Option = .home
    @Published var doubleChanceOption: BetSelection.DoubleChanceOption = .homeOrDraw
    @Published var score: String = "0:0"
    
    init(match: Match) {
        self.match = match
        self.bet = Bet.loadFromFile(match: match.matchId) ?? Bet(matchString: match.matchId, events: [])
    }
    
    var validTypesForSelectedName: [BetType] {
        switch selectedName {
        case .btts: return [.yesOrNo]
        case .totalGoals, .totalCards, .totalCorners: return [.underOrOver]
        case .chance: return [.chance3, .doubleChance3]
        case .correctScore: return [.correctScore]
        }
    }
    
    func updateTypeIfInvalid() {
        if !validTypesForSelectedName.contains(selectedType) {
            selectedType = validTypesForSelectedName.first ?? .yesOrNo
        }
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
    
    func deleteAllEvents() {
        bet?.events.removeAll()
        bet?.saveToFile()
    }
}
