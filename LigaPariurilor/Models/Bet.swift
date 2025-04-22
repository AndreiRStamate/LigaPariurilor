//
//  Bet.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 22.04.2025.
//

import Foundation

struct Bet: Identifiable, Codable {
    var id = UUID()
    var matchString: String
    var events: [BetEvent]
    
    func saveToFile() {
        let fileManager = FileManager.default
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = directory.appendingPathComponent("bet-\(matchString).json")

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        if let data = try? encoder.encode(self) {
            try? data.write(to: fileURL)
        }
    }
    
    static func loadFromFile(match: String) -> Bet? {
        let fileManager = FileManager.default
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = directory.appendingPathComponent("bet-\(match).json")
        guard let data = try? Data(contentsOf: fileURL) else { return nil }

        let decoder = JSONDecoder()
        return try? decoder.decode(Bet.self, from: data)
    }
}

struct BetEvent: Identifiable, Codable {
    var id = UUID()
    var name: BetEventName
    var type: BetType
    var selection: BetSelection
}

enum BetType: String, Codable {
    case yesOrNo
    case underOrOver
    case chance3
    case doubleChance3
    case correctScore
}

enum BetSelection: Codable {
    case yesOrNo(Bool) // true for "yes", false for "no"
    case underOrOver(Bound, Double) // like over 2.5 or under 2.5
    case chance3(Chance3Option)
    case doubleChance3(DoubleChanceOption)
    case correctScore(String) // e.g., "2:2"

    enum Bound: Codable {
        case over
        case under
    }

    enum Chance3Option: String, Codable, CaseIterable {
        case home = "1"
        case draw = "x"
        case away = "2"
    }

    enum DoubleChanceOption: String, Codable, CaseIterable {
        case homeOrDraw = "1x"
        case drawOrAway = "x2"
        case homeOrAway = "12"
    }
}

enum BetEventName: String, Codable, CaseIterable {
    case btts = "GG"
    case totalGoals = "Total Goluri"
    case totalCards = "Total Cartonașe"
    case totalCorners = "Total Cornere"
    case chance = "Șansă"
    case correctScore = "Scor Corect"
}

extension BetEvent {
    static func bttsYes() -> BetEvent {
        return BetEvent(name: .btts, type: .yesOrNo, selection: .yesOrNo(true))
    }

    static func bttsNo() -> BetEvent {
        return BetEvent(name: .btts, type: .yesOrNo, selection: .yesOrNo(false))
    }

    static func totalGoals(over value: Double) -> BetEvent {
        return BetEvent(name: .totalGoals, type: .underOrOver, selection: .underOrOver(.over, value))
    }
    
    static func totalGoals(under value: Double) -> BetEvent {
        return BetEvent(name: .totalGoals, type: .underOrOver, selection: .underOrOver(.under, value))
    }

    static func chance(_ option: BetSelection.Chance3Option) -> BetEvent {
        return BetEvent(name: .chance, type: .chance3, selection: .chance3(option))
    }

    static func totalCards(over value: Double) -> BetEvent {
        return BetEvent(name: .totalCards, type: .underOrOver, selection: .underOrOver(.over, value))
    }

    static func totalCards(under value: Double) -> BetEvent {
        return BetEvent(name: .totalCards, type: .underOrOver, selection: .underOrOver(.under, value))
    }

    static func totalCorners(over value: Double) -> BetEvent {
        return BetEvent(name: .totalCorners, type: .underOrOver, selection: .underOrOver(.over, value))
    }

    static func totalCorners(under value: Double) -> BetEvent {
        return BetEvent(name: .totalCorners, type: .underOrOver, selection: .underOrOver(.under, value))
    }

    static func doubleChance(_ option: BetSelection.DoubleChanceOption) -> BetEvent {
        return BetEvent(name: .chance, type: .doubleChance3, selection: .doubleChance3(option))
    }

    static func correctScore(_ score: String) -> BetEvent {
        let pattern = #"^\d+:\d+$"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: score.utf16.count)
        let isValid = regex?.firstMatch(in: score, options: [], range: range) != nil
        let validScore = isValid ? score : "0:0"

        return BetEvent(name: .correctScore, type: .correctScore, selection: .correctScore(validScore))
    }
}
