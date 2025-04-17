//
//  FileDetailView.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import SwiftUI

struct FileDetailView: View {
    let fileName: String
    @StateObject private var viewModel = JSONViewModel()

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
                viewModel.sortMatches()
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
                        viewModel.fetchJSON(from: fileName)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else if !viewModel.matches.isEmpty {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.matches) { match in
                            NavigationLink(destination: MatchDetailView(match: match)) {
                                MatchBoxView(match: match)
                            }
                        }
                    }
                    .padding()
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
            viewModel.fetchJSON(from: fileName)
        }
    }
}
