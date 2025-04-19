//
//  MatchBoxViewModel.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 19.04.2025.
//

import Foundation

enum MatchOutcome {
  case unpredictable, predictable
}

struct MatchBoxViewModel {
    let match: Match

    var outcome: MatchOutcome {
        match.predictability < 1.0 ? .predictable : .unpredictable
    }

    var displayTeams: String {
        "\(match.team1) vs \(match.team2)"
    }

    var displayDate: String {
        return formattedDate(match.commenceTime)
    }
}
