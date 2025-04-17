//
//  MatchBoxView.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import SwiftUI

struct MatchBoxView: View {
    let match: Match

    private func formattedDate(_ isoString: String) -> String {
        if let date = ISO8601DateFormatter().date(from: isoString) {
            let calendar = Calendar.current
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            if calendar.isDateInToday(date) {
                return "Azi la \(timeFormatter.string(from: date))"
            } else if calendar.isDateInTomorrow(date) {
                return "Mâine la \(timeFormatter.string(from: date))"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyyy HH:mm"
                return formatter.string(from: date)
            }
        }
        return isoString
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(match.team1) vs \(match.team2)")
                .font(.subheadline)
            Text(formattedDate(match.commenceTime))
                .font(.caption)
            HStack {
                Text(String(format: "Predictabilitate: %.2f", match.predictability))
                    .font(.caption2)
                Spacer()
                Text(match.action)
                    .font(.caption2)
                    .foregroundColor(match.predictability < 1.0 ? .green : .red)
            }
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
