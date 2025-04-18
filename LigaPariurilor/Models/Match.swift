//
//  Match.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import Foundation

struct Match: Identifiable {
    let id = UUID()
    let league: String
    let team1: String
    let team2: String
    let odds: [String: Double]
    let commenceTime: String
    let predictability: Double
    let action: String
    
    /// Default analysis template with placeholders
    static let defaultAnalysisTemplate = """
    Match: {team1} vs {team2}
    Competition: {league}
    Date & Time: {commenceTime}

    Please consider the following:
    • Recent form (last 5 matches)
    • League standings
    • Injuries/suspensions
    • Weather forecast
    • Referee
    • Head-to-head record
    • Tactical styles
    • Odds movement if relevant
    • Possible fatigue

    At the end, provide:
    • 5 likely bets with brief explanations
    • 3 high-probability bets with strong justifications
    """

    var formattedAnalysis: String {
        let template = UserDefaults.standard.string(forKey: "analysisTemplate") ?? Self.defaultAnalysisTemplate
        return template
            .replacingOccurrences(of: "{team1}", with: team1)
            .replacingOccurrences(of: "{team2}", with: team2)
            .replacingOccurrences(of: "{league}", with: league)
            .replacingOccurrences(of: "{commenceTime}", with: commenceTime)
    }
}
