//
//  FootballListPage.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 18.04.2025.
//

import SwiftUI

struct FootballListPage: View {
    @StateObject var viewModel: FootballListViewModel = .init()
    @State private var refreshFlag = UUID()
    @State private var showingSettings = false
    @AppStorage("analysisFootballTemplate") private var analysisFootballTemplate: String = Match.defaultFootballAnalysisTemplate

    var body: some View {
        NavigationView {
            VStack {
                searchBar
                toggleView
                contentView
                toastView
            }
            .padding(.top, 20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Ligi Disponibile")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings.toggle()
                    }) {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                NavigationView {
                    Form {
                        Section(header: Text("Șablon prompt").font(.subheadline)) {
                            TextEditor(text: $analysisFootballTemplate)
                                .font(.callout)
                                .frame(minHeight: 200)
                        }
                        Section(header: Text("Cuvinte cheie").font(.subheadline)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("{team1} – Echipa gazdă")
                                Text("{team2} – Echipa oaspete")
                                Text("{league} – Competiție/Ligă")
                                Text("{commenceTime} – Dată și oră")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        Section {
                            Button("Revino la prompt-ul inițial") {
                                analysisFootballTemplate = Match.defaultFootballAnalysisTemplate
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .navigationTitle("Editare prompt")
                    .navigationBarItems(trailing: Button("Gata") {
                        showingSettings = false
                    })
                }
            }
            .onAppear(perform: viewModel.fetchFileList)
        }
    }

    @ViewBuilder
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search", text: $viewModel.searchText)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    @ViewBuilder
    private var toggleView: some View {
        Toggle("Favorite", isOn: $viewModel.showFavoritesOnly)
            .padding(.horizontal)
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            ProgressView("Loading files...")
        } else if let message = viewModel.errorMessage {
            VStack(spacing: 12) {
                Text("Eroare: \(message)")
                    .foregroundColor(.red)
                Button("Reîncarcă") {
                    viewModel.errorMessage = nil
                    viewModel.isLoading = true
                    viewModel.fetchFileList()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        } else {
            List {
                ForEach(viewModel.groupedAndSortedFiles, id: \.key) { section in
                    Section(header: Text(section.key)) {
                        ForEach(section.value) { file in
                            NavigationLink(destination: FileDetailView(fileName: file.fileName, url: APIConfig.footballURL, sportsType: "football")) {
                                FootballFileRow(
                                    file: file,
                                    refreshFlag: $refreshFlag,
                                    viewModel: viewModel
                                )
                            }
                            .id(refreshFlag)
                        }
                    }
                }
            }
            .animation(.easeInOut, value: viewModel.showFavoritesOnly)
            .refreshable {
                viewModel.fetchFileListWithoutCache()
            }
        }
    }

    @ViewBuilder
    private var toastView: some View {
        if viewModel.showToast {
            Text("Datele au fost actualizate.")
                .font(.caption)
                .padding(8)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.bottom, 16)
                .transition(.opacity)
        }
    }

    
}

struct FootballFileRow: View {
    let file: LeagueFile
    @Binding var refreshFlag: UUID
    @ObservedObject var viewModel: FootballListViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(file.displayName.uppercased())
                    .font(.system(size: 14, design: .monospaced))
                Text(file.fileName
                        .replacingOccurrences(of: "api_response_", with: "")
                        .replacingOccurrences(of: ".json", with: ""))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            if viewModel.refreshingFile == file.fileName {
                ProgressView()
                    .scaleEffect(0.6)
            } else if isStale(fileName: file.fileName) {
                Image(systemName: "arrow.clockwise.circle")
                    .foregroundColor(.orange)
                    .onTapGesture {
                        viewModel.refreshingFile = file.fileName
                        fetchAndCacheFile(file.fileName, url: APIConfig.footballURL)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            viewModel.refreshingFile = nil
                            refreshFlag = UUID()
                            viewModel.showToast = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                viewModel.showToast = false
                            }
                        }
                    }
            }
            Image(systemName: viewModel.favoriteFileNames.contains(file.fileName) ? "star.fill" : "star")
                .foregroundColor(.yellow)
                .onTapGesture {
                    FootballListViewModel.toggleFavorite(file.fileName)
                    viewModel.favoriteFileNames = FootballListViewModel.loadFavoriteFileNames()
                }
                .padding(.leading, 8)
        }
        .padding(.vertical, 4)
    }
}
