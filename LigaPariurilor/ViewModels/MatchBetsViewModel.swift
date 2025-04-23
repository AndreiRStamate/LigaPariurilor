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
    @Published var homeScore: Int = 0
    @Published var awayScore: Int = 0
    @Published var selectedGroupKey: String = "main"
    @Published var newGroupName: String = ""
    
    init(match: Match) {
        self.match = match
        self.bet = Bet.loadFromFile(match: match.matchId) ?? Bet(matchString: match.matchId, eventGroups: ["main": []])
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
        if bet?.eventGroups[selectedGroupKey] == nil {
            bet?.eventGroups[selectedGroupKey] = []
        }
        if let index = bet?.eventGroups[selectedGroupKey]?.firstIndex(where: { $0.name == event.name }) {
            bet?.eventGroups[selectedGroupKey]?[index] = event
        } else {
            bet?.eventGroups[selectedGroupKey]?.append(event)
        }
        bet?.saveToFile()
    }

    func deleteEvent(_ event: BetEvent) {
        if let index = bet?.eventGroups[selectedGroupKey]?.firstIndex(where: { $0.id == event.id }) {
            bet?.eventGroups[selectedGroupKey]?.remove(at: index)
            bet?.saveToFile()
        }
    }
    
    func deleteAllEvents() {
        bet?.eventGroups[selectedGroupKey]?.removeAll()
        bet?.saveToFile()
    }
    
    func toggleWon(for event: BetEvent) {
        guard let index = bet?.eventGroups[selectedGroupKey]?.firstIndex(where: { $0.id == event.id }) else { return }
        var current = bet!.eventGroups[selectedGroupKey]![index].won
        switch current {
        case .none:
            current = true
        case .some(true):
            current = false
        case .some(false):
            current = nil
        }
        bet!.eventGroups[selectedGroupKey]![index].won = current
        bet?.saveToFile()
    }
    
    func addGroup() {
        let trimmedName = newGroupName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, bet?.eventGroups[trimmedName] == nil else { return }
        bet?.eventGroups[trimmedName] = []
        selectedGroupKey = trimmedName
        newGroupName = ""
        bet?.saveToFile()
    }

    func deleteCurrentGroup() {
        guard selectedGroupKey != "main" else { return }
        bet?.eventGroups.removeValue(forKey: selectedGroupKey)
        selectedGroupKey = "main"
        bet?.saveToFile()
    }
}
