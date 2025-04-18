//
//  MatchBoxView.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import SwiftUI

struct MatchBoxView: View {
    let match: Match

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(match.team1) vs \(match.team2)")
                    .font(.subheadline)
                    .foregroundColor(Color.primary)
                Text(formattedDate(match.commenceTime))
                    .font(.caption)
                    .foregroundColor(Color.primary)
                HStack {
                    Text(match.action)
                        .font(.caption2)
                        .foregroundColor(match.predictability < 1.0 ? .green : .red)
                    Spacer()
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .contentShape(RoundedRectangle(cornerRadius: 8))
    }
}
