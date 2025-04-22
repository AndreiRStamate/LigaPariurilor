//
//  MatchBetsView.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 22.04.2025.
//

import SwiftUI

struct MatchBetsView: View {
    @StateObject private var viewModel: MatchBetsViewModel
    @State private var eventToDelete: BetEvent?
    
    init(match: Match) {
        _viewModel = StateObject(wrappedValue: MatchBetsViewModel(match: match))
    }
    
    var body: some View {
        VStack {
            if let bet = viewModel.bet {
                List {
                    ForEach(bet.events) { event in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(event.name.rawValue)
                                Text(displaySelection(event.selection))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(action: {
                                eventToDelete = event
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                Divider().padding(.vertical)
                
                Text("Add Bet Event")
                    .font(.headline)
                
                HStack {
                    Button("BTTS Yes") {
                        viewModel.addEvent(BetEvent.bttsYes())
                    }
                    Button("BTTS No") {
                        viewModel.addEvent(BetEvent.bttsNo())
                    }
                }
                
                HStack {
                    Button("Over 2.5 Goals") {
                        viewModel.addEvent(BetEvent.totalGoals(over: 2.5))
                    }
                    Button("Correct Score 2:2") {
                        viewModel.addEvent(BetEvent.correctScore("2:2"))
                    }
                }
            } else {
                Text("Loading bet...")
            }
        }
        .alert(item: $eventToDelete) { event in
            Alert(
                title: Text("Delete Bet"),
                message: Text("Are you sure you want to delete this bet event?"),
                primaryButton: .destructive(Text("Delete")) {
                    viewModel.deleteEvent(event)
                },
                secondaryButton: .cancel()
            )
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
