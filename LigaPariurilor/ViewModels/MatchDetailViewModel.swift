//
//  MatchDetailViewModel.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 19.04.2025.
//

import Foundation
import SwiftUI
import UIKit

final class MatchDetailViewModel: ObservableObject {
    let match: Match
    let sportsType: String
    
    @Published var animateOdds = false
    @Published var showRecommendation = false
    @Published var showingAnalysis = false
    @Published var showCopyToast = false
    
    init(match: Match, sportsType: String) {
        self.match = match
        self.sportsType = sportsType
    }
    
    func onAppear() {
        animateOdds = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut) {
                self.showRecommendation = true
            }
        }
    }
    
    var displayDate: String {
        let isoFormatter = ISO8601DateFormatter()
        guard let date = isoFormatter.date(from: match.commenceTime) else {
            return match.commenceTime
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, HH:mm"
        return formatter.string(from: date)
    }
    
    var oddsArray: [(team: String, odd: Double)] {
        [
            (match.team1, match.odds[match.team1] ?? 0.0),
            (match.team2, match.odds[match.team2] ?? 0.0)
        ]
    }
    
    var allEqualOdds: Bool {
        Set(oddsArray.map { $0.odd }).count == 1
    }
    
    var minOdd: Double {
        oddsArray.map { $0.odd }.min() ?? 0.0
    }
    
    var maxOdd: Double {
        oddsArray.map { $0.odd }.max() ?? 0.0
    }
    
    var analysisPrompt: String {
        match.getAnalysisTemplate(for: sportsType)
    }
    
    func copyAnalysis() {
        UIPasteboard.general.string = analysisPrompt
        showCopyToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showCopyToast = false
        }
    }
    
    enum ChatDestination {
        case chatGPT, gemini, grok, claude
        
        var url: URL? {
            switch self {
            case .chatGPT:
                return URL(string: "chatgpt://")
            case .gemini:
                return URL(string: "https://gemini.google.com")
            case .grok:
                return URL(string: "https://grok.x.ai")
            case .claude:
                return URL(string: "https://claude.ai")
            }
        }
        
        var fallbackURL: URL? {
            switch self {
            case .chatGPT:
                return URL(string: "https://apps.apple.com/app/openai-chatgpt/id6448311069")
            default:
                return nil
            }
        }
    }
    
    func open(_ destination: ChatDestination) {
        guard let url = destination.url else { return }
        UIApplication.shared.open(url, options: [:]) { success in
            if !success, let fallback = destination.fallbackURL {
                UIApplication.shared.open(fallback)
            }
        }
    }
}
