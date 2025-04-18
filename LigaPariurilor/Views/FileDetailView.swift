//
//  FileDetailView.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import SwiftUI

struct FileDetailView: View {
    let fileName: String
    let url: URL
    let sportsType: String
    @StateObject private var viewModel = JSONViewModel()
    @State private var showPastEvents = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Sort by", selection: $viewModel.sortMode) {
                Text("Evaluare").tag(SortMode.predictability)
                Text("Dată").tag(SortMode.commenceTime)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.top)
            .onChange(of: viewModel.sortMode) {
                withAnimation(.easeInOut) {
                    viewModel.sortMatches()
                }
            }

            if viewModel.matches.contains(where: {
                guard let date = ISO8601DateFormatter().date(from: $0.commenceTime) else { return false }
                return date <= Date()
            }) {
                Toggle("Afișează evenimentele trecute", isOn: $showPastEvents)
                    .padding(.horizontal)
            }

            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity)
                Spacer()
            } else if let error = viewModel.errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Text("Eroare: \(error)")
                        .foregroundColor(.red)
                    Button("Încearcă din nou") {
                        viewModel.fetchJSON(from: fileName, url: url)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else if !viewModel.matches.isEmpty {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.matches.filter {
                            guard let date = ISO8601DateFormatter().date(from: $0.commenceTime) else { return false }
                            return showPastEvents || date > Date()
                        }) { match in
                            NavigationLink(destination: MatchDetailView(match: match, sportsType: sportsType)) {
                                MatchBoxView(match: match)
                            }
                        }
                    }
                    .padding()
                    .animation(.easeInOut, value: showPastEvents)
                }
            } else {
                Spacer()
                Text("Niciun meci găsit.")
                    .frame(maxWidth: .infinity)
                Spacer()
            }
        }
        .padding(.bottom)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text({
                    let trimmed = fileName
                        .replacingOccurrences(of: "api_response_", with: "")
                        .replacingOccurrences(of: ".json", with: "")
                    return (LeagueInfo.names[trimmed] ?? trimmed).uppercased()
                }())
                .font(.system(size: 14, weight: .semibold, design: .default))
            }
        }
        .onAppear {
            viewModel.fetchJSON(from: fileName, url: url)
        }
    }
}
