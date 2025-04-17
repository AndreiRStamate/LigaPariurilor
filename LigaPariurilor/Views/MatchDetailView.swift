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
    @State private var showingAnalysis = false
    @State private var showCopyToast = false

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
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb")
                        .foregroundColor(.accentColor)
                        .frame(width: 24)
                    Text("Recomandare: \(match.action)")
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Button(action: {
                showingAnalysis = true
            }) {
                HStack {
                    Image(systemName: "doc.text.magnifyingglass")
                        .foregroundColor(.accentColor)
                        .frame(width: 24)
                    Text("Afișează Prompt")
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .sheet(isPresented: $showingAnalysis) {
                VStack(alignment: .leading, spacing: 16) {
                    ScrollView {
                        Text(match.formattedAnalysis)
                            .font(.callout)
                            .foregroundColor(.primary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding()

                    Button(action: {
                        UIPasteboard.general.string = match.formattedAnalysis
                        showCopyToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showCopyToast = false
                        }
                    }) {
                        Label("Copiază prompt", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                .presentationDetents([.medium, .large])
                .overlay(
                    Group {
                        if showCopyToast {
                            Text("Prompt-ul a fost copiat")
                                .font(.caption)
                                .padding(8)
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding(.bottom, 20)
                                .transition(.opacity)
                        }
                    },
                    alignment: .bottom
                )
            }

            Group {
                Button(action: {
                    if let url = URL(string: "chatgpt://") {
                        UIApplication.shared.open(url, options: [:]) { success in
                            if !success {
                                if let appStoreURL = URL(string: "https://apps.apple.com/app/openai-chatgpt/id6448311069") {
                                    UIApplication.shared.open(appStoreURL)
                                }
                            }
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .foregroundColor(.accentColor)
                            .frame(width: 24)
                        Text("Deschide ChatGPT")
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                }

                Button(action: {
                    if let url = URL(string: "https://gemini.google.com") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.accentColor)
                            .frame(width: 24)
                        Text("Deschide Gemini")
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                }

                Button(action: {
                    if let url = URL(string: "https://grok.x.ai") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "bolt.horizontal")
                            .foregroundColor(.accentColor)
                            .frame(width: 24)
                        Text("Deschide Grok")
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                }

                Button(action: {
                    if let url = URL(string: "https://claude.ai") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.accentColor)
                            .frame(width: 24)
                        Text("Deschide Claude")
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

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
