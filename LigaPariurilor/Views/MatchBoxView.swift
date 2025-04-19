//
//  MatchBoxView.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import SwiftUI

struct MatchBoxView: View {
    private let viewModel: MatchBoxViewModel

    init(match: Match) {
        self.viewModel = MatchBoxViewModel(match: match)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.displayTeams)
                    .font(.subheadline)
                    .foregroundColor(Color.primary)
                Text(viewModel.displayDate)
                    .font(.caption)
                    .foregroundColor(Color.primary)
                HStack {
                    Text(viewModel.match.action)
                        .font(.caption2)
                        .foregroundColor(viewModel.outcome == .predictable ? .green : .red)
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
