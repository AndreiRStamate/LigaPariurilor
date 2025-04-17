//
//  MatchDetailView.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import SwiftUI

struct MatchDetailView: View {
    let match: Match

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LeagueInfo.names[match.league] ?? match.league)
                .font(.title2)
                .bold()
            Text("\(match.team1) vs \(match.team2)")
                .font(.title3)
            Text("Ora de start: \(match.commenceTime)")
                .font(.subheadline)

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text("Cote:")
                    .font(.headline)
                ForEach(match.odds.sorted(by: { $0.key < $1.key }), id: \.key) { team, odd in
                    Text("\(team): \(odd)")
                }
            }

            Divider()

            Text("Predictabilitate: \(String(format: "%.2f", match.predictability))")
            Text("Recomandare: \(match.action)")
                .foregroundColor(match.predictability < 1.0 ? .green : .red)

            Spacer()
        }
        .padding()
        .navigationTitle("Detalii Meci")
        .navigationBarTitleDisplayMode(.inline)
    }
}
