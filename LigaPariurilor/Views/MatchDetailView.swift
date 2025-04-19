//
//  MatchDetailView.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import SwiftUI

struct MatchDetailView: View {
    @StateObject private var viewModel: MatchDetailViewModel

    init(match: Match, sportsType: String) {
        _viewModel = StateObject(wrappedValue: MatchDetailViewModel(match: match, sportsType: sportsType))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .center, spacing: 2) {
                    Text(viewModel.match.team1)
                    Text("vs \(viewModel.match.team2)")
                }
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)

                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                    Text("Ora de start: \(viewModel.displayDate)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    ForEach(Array(viewModel.oddsArray.enumerated()), id: \.element.team) { index, element in
                        let team = element.team
                        let odd = element.odd
                        VStack(spacing: 4) {
                            Text(team)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(String(format: "%.2f", odd))
                                .font(.body)
                                .bold()
                                .foregroundColor(viewModel.allEqualOdds ? .primary : (odd == viewModel.minOdd ? .dynamicGreen : (odd == viewModel.maxOdd ? .dynamicRed : .primary)))
                        }
                        .frame(maxWidth: .infinity)
                        .opacity(viewModel.animateOdds ? 1 : 0)
                        .scaleEffect(viewModel.animateOdds ? 1 : 0.9)
                        .animation(.easeOut.delay(Double(index) * 0.1), value: viewModel.animateOdds)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }

            if !viewModel.match.action.isEmpty && viewModel.showRecommendation {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb")
                        .foregroundColor(.accentColor)
                        .frame(width: 24)
                    Text("Recomandare: \(viewModel.match.action)")
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
                viewModel.showingAnalysis = true
            }) {
                HStack {
                    Image(systemName: "doc.text.magnifyingglass")
                        .foregroundColor(.accentColor)
                        .frame(width: 24)
                    Text("Afișează Prompt")
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .sheet(isPresented: $viewModel.showingAnalysis) {
                analysisSheet
            }

            Group {
                Button(action: {
                    viewModel.open(.chatGPT)
                }) {
                    HStack {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .foregroundColor(.accentColor)
                            .frame(width: 24)
                        Text("Deschide ChatGPT")
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }

                Button(action: {
                    viewModel.open(.gemini)
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.accentColor)
                            .frame(width: 24)
                        Text("Deschide Gemini")
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }

                Button(action: {
                    viewModel.open(.grok)
                }) {
                    HStack {
                        Image(systemName: "bolt.horizontal")
                            .foregroundColor(.accentColor)
                            .frame(width: 24)
                        Text("Deschide Grok")
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }

                Button(action: {
                    viewModel.open(.claude)
                }) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.accentColor)
                            .frame(width: 24)
                        Text("Deschide Claude")
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
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
            viewModel.onAppear()
        }
    }

    private var analysisSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView {
                Text(viewModel.analysisPrompt)
                    .font(.callout)
                    .foregroundColor(.primary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding()

            Button(action: {
                viewModel.copyAnalysis()
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
                if viewModel.showCopyToast {
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
