//
//  MatchBetsView.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 22.04.2025.
//

import SwiftUI

struct MatchBetsView: View {
    @StateObject private var viewModel: MatchBetsViewModel
    
    init(match: Match) {
        _viewModel = StateObject(wrappedValue: MatchBetsViewModel(match: match))
    }
    
    var body: some View {
        VStack {
            if let bet = viewModel.bet {
                List {
                    ForEach(bet.events) { event in
                        HStack {
                            Text(event.name.rawValue)
                            Spacer()
                            Text(displaySelection(event.selection))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Divider().padding(.vertical)
                
                Text("Add Bet Event")
                    .font(.headline)
                
                HStack {
                    Button("BTTS Yes") {
                        viewModel.bet?.events.append(BetEvent.bttsYes())
                        viewModel.bet?.saveToFile()
                    }
                    Button("BTTS No") {
                        viewModel.bet?.events.append(BetEvent.bttsNo())
                        viewModel.bet?.saveToFile()
                    }
                }
                
                HStack {
                    Button("Over 2.5 Goals") {
                        viewModel.bet?.events.append(BetEvent.totalGoals(over: 2.5))
                        viewModel.bet?.saveToFile()
                    }
                    Button("Correct Score 2:2") {
                        viewModel.bet?.events.append(BetEvent.correctScore("2:2"))
                        viewModel.bet?.saveToFile()
                    }
                }
            } else {
                Text("Loading bet...")
            }
        }
        .navigationTitle("Lista pariurilor")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func displaySelection(_ selection: BetSelection) -> String {
        switch selection {
        case .yesOrNo(let value):
            return value ? "Yes" : "No"
        case .underOrOver(let bound, let value):
            return "\(bound == .over ? "Over" : "Under") \(value)"
        case .chance3(let option):
            return option.rawValue
        case .doubleChance3(let option):
            return option.rawValue
        case .correctScore(let score):
            return score
        }
    }
}
