//
//  MatchDetailView.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import SwiftUI

struct MatchDetailView: View {
    let match: Match
    @State private var animateOdds = false
    @State private var showRecommendation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .center, spacing: 2) {
                    Text(match.team1)
                    Text("vs \(match.team2)")
                }
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)

                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                    Text("Ora de start: \(formattedDate(match.commenceTime))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 12) {

                let oddsArray = match.odds.map { $0.value }
                let allEqual = Set(oddsArray).count == 1
                let minOdd = oddsArray.min() ?? 0
                let maxOdd = oddsArray.max() ?? 0

                HStack(spacing: 16) {
                    ForEach([match.team1, match.team2].enumerated().map { ($0.offset, ($0.element, match.odds[$0.element] ?? 0.0)) }, id: \.1.0) { index, element in
                        let team = element.0
                        let odd = element.1
                        VStack(spacing: 4) {
                            Text(team)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(String(format: "%.2f", odd))
                                .font(.body)
                                .bold()
                                .foregroundColor(allEqual ? .primary : (odd == minOdd ? .dynamicGreen : (odd == maxOdd ? .dynamicRed : .primary)))
                        }
                        .frame(maxWidth: .infinity)
                        .opacity(animateOdds ? 1 : 0)
                        .scaleEffect(animateOdds ? 1 : 0.9)
                        .animation(.easeOut.delay(Double(index) * 0.1), value: animateOdds)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }

            if !match.action.isEmpty && showRecommendation {
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "lightbulb")
                        .foregroundColor(.accentColor)
                    Text("Recomandare: \(match.action)")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer()
        }
        .padding()
        .padding()
        .navigationTitle("Detalii Meci")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            animateOdds = true
            withAnimation(.easeOut.delay(0.3)) {
                showRecommendation = true
            }
        }
    }

    private func formattedDate(_ isoDateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        guard let date = isoFormatter.date(from: isoDateString) else { return isoDateString }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, HH:mm"
        return formatter.string(from: date)
    }
}

extension Color {
    static var dynamicGreen: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.systemGreen.withAlphaComponent(0.8) : UIColor.systemGreen
        })
    }

    static var dynamicRed: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.systemRed.withAlphaComponent(0.8) : UIColor.systemRed
        })
    }
}
