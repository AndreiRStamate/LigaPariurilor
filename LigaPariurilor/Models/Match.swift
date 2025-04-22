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
    
    var matchId: String {
        "\(team1)_\(team2)"
    }

    private static let defaultFootballAnalysisTemplate = """
    Match Preview & Betting Analysis Request
    Match Details:
    Match: {team1} (Home) vs {team2} (Away)
    Competition: {league}
    Date & Time: {commenceTime}
    Analysis Factors to Consider:
    Recent Form:
    Overall form (last 5-6 matches - W/D/L, goals scored/conceded) for both teams.
    Home/Away Specific Form: Analyze {team1}'s record and performance trends at home vs {team2}'s record and performance trends away.
    League Standings & Season Context:
    Current table position, points, goal difference.
    Implications based on their standings (title race, European qualification, relegation battle).
    Match Context & Motivation:
    Significance of this specific match (derby, rivalry, cup tie, end-of-season importance).
    Assess potential motivation levels for both sides.
    Team News:
    Confirmed injuries and suspensions.
    Players doubtful or returning from absence.
    Relevant internal team news (e.g., managerial pressure, dressing room conflicts).
    Head-to-Head (H2H) Record:
    Results of recent meetings (last 3-5).
    Historical trends or patterns specific to this fixture.
    Tactical Analysis:
    Likely formations and playing styles (possession-based, counter-attack, high press, defensive approach).
    Identify 1-2 Key Player Matchups that could significantly influence the game outcome.
    Disciplinary & Potential Faults:
    Identify players most likely to commit fouls or receive bookings based on recent disciplinary records.
    Highlight players or teams prone to conceding penalties or dangerous set-pieces due to reckless defending.
    Assess teams' historical disciplinary records (cards frequency, sending-offs).
    External Factors:
    Weather Forecast: Predicted conditions (rain, wind, temperature) and potential impact.
    Referee: Assigned referee and their relevant statistics (card frequency, penalty decisions).
    Physical Condition:
    Assess Possible Fatigue based on recent scheduling, travel, and minutes played by key players.
    Market Indicators:
    Note significant Odds Movement if observable, and potential reasons behind it (injuries, team news).
    Advanced Stats:
    Recent Expected Goals (xG) trends (performance vs. underlying chances created/conceded), if data is readily available.
    You can find most recent data on flashscore. Don’t use information older than 2 weeks. If you’re not sure of some statistic don’t include it in your calculations.
    Required Output:
    Based on the comprehensive analysis above:
    Provide 5 plausible betting predictions covering diverse markets (e.g., Match Result, Goals Over/Under, Both Teams to Score, Player Props, Handicaps, Card Markets) with brief explanations.
    Specifically include predictions related to disciplinary actions (cards, fouls committed).
    Identify 3 bets considered to have a higher probability of success, clearly linked to the analyzed factors, including disciplinary records, tactical matchups, and recent form.
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
