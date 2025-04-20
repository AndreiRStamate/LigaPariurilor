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
    
    private static let defaultFootballAnalysisTemplate = """
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
    
    private static let defaultBasketballAnalysisTemplate = """
    Give me the 5 most likely bets to hit for the {team1} vs {team2} game on {commenceTime}
    Consider the following factors in your analysis:
    • Current player formations and rotations
    • Recent team performance and trends
    • The time of the game and its potential impact
    • Historical matchups between these teams, including results from the current season
    • Player injuries and their betting implications
    • Individual player matchups, including historical performance against specific opponents (regardless of which teams they previously played for)
    • The referees assigned to the game, their historical foul-calling tendencies, and their impact on specific players or teams
    • Suggest any bet type available on sportsbooks (spreads, totals, player props, specials, etc). For each recommended bet, explain the reasoning and data behind the suggestion.
    """
    
    private static let defaultHockeyAnalysisTemplate = """
    Provide an analysis for the {team1} vs {team2} hockey game on {commenceTime} in {league}.
    
    Consider these factors:
    • Team form and recent results (last 5 games)  
    • Goalie performance and save percentage  
    • Power play and penalty kill efficiencies  
    • Injuries and roster changes  
    • Home/away performance splits  
    • Head-to-head history  
    • Special teams and faceoff win rates  
    • Travel, rest, and fatigue
    
    At the end, provide:
    • 5 recommended bets with brief rationales  
    • 3 high-confidence bets with detailed justification  
    """
    
    private static let defaultCricketAnalysisTemplate = """
    Match: {team1} vs {team2}
    Competition: {league}
    Date & Time: {commenceTime}

    Please analyze and consider the following aspects:
    • Recent form (last 5 matches)
    • Current standings or series context (including points table or series scoreline)
    • Injuries and suspensions (including updates on key players)
    • Pitch report and ground history (how the surface behaves, average scores, etc.)
    • Weather forecast (including rain interruptions, dew factor, etc.)
    • Umpiring crew (especially any known tendencies or controversies)
    • Head-to-head record
    • Team composition and balance (batting depth, bowling variety, bench strength)
    • Tactical approaches (batting tempo, powerplay usage, spin vs pace strategy)
    • Toss impact (historical data on win/loss after toss at venue)
    • Odds movement (if relevant)
    • Possible fatigue or scheduling impact (travel, back-to-back games, etc.)

    At the end, provide:
    • 5 likely bets with brief reasoning behind each
    • 3 high-probability bets with strong justifications
    """
    
    private var formattedFootballAnalysis: String {
        let template = UserDefaults.standard.string(forKey: "analysisTemplate_football") ?? Self.defaultFootballAnalysisTemplate
        return template
            .replacingOccurrences(of: "{team1}", with: team1)
            .replacingOccurrences(of: "{team2}", with: team2)
            .replacingOccurrences(of: "{league}", with: league)
            .replacingOccurrences(of: "{commenceTime}", with: commenceTime)
    }
    
    private var formattedBasketballAnalysis: String {
        let template = UserDefaults.standard.string(forKey: "analysisTemplate_basketball") ?? Self.defaultBasketballAnalysisTemplate
        return template
            .replacingOccurrences(of: "{team1}", with: team1)
            .replacingOccurrences(of: "{team2}", with: team2)
            .replacingOccurrences(of: "{league}", with: league)
            .replacingOccurrences(of: "{commenceTime}", with: commenceTime)
    }
    
    private var formattedHockeyAnalysis: String {
        let template = UserDefaults.standard.string(forKey: "analysisTemplate_hockey") ?? Self.defaultHockeyAnalysisTemplate
        return template
            .replacingOccurrences(of: "{team1}", with: team1)
            .replacingOccurrences(of: "{team2}", with: team2)
            .replacingOccurrences(of: "{league}", with: league)
            .replacingOccurrences(of: "{commenceTime}", with: commenceTime)
    }
    
    private var formattedCricketAnalysis: String {
        let template = UserDefaults.standard.string(forKey: "analysisTemplate_cricket") ?? Self.defaultCricketAnalysisTemplate
        return template
            .replacingOccurrences(of: "{team1}", with: team1)
            .replacingOccurrences(of: "{team2}", with: team2)
            .replacingOccurrences(of: "{league}", with: league)
            .replacingOccurrences(of: "{commenceTime}", with: commenceTime)
    }
    
    func getAnalysisTemplate(for sport: String) -> String {
        switch sport {
        case "football":
            return formattedFootballAnalysis
        case "basketball":
            return formattedBasketballAnalysis
        case "hockey":
            return formattedHockeyAnalysis
        case "cricket":
            return formattedCricketAnalysis
        default:
            return ""
        }
    }
    
    static func getDefaultAnalysisTemplate(sport: String) -> String {
        switch sport {
        case "football":
            return defaultFootballAnalysisTemplate
        case "basketball":
            return defaultBasketballAnalysisTemplate
        case "hockey":
            return defaultHockeyAnalysisTemplate
        case "cricket":
            return defaultCricketAnalysisTemplate
        default:
            return ""
        }
    }
}
