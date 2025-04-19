//
//  SportListPage.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 19.04.2025.
//

import SwiftUI

struct SportListPage: View {
    let sportType: SportType
    @StateObject private var viewModel: SportListViewModel

    init(sportType: SportType) {
        self.sportType = sportType
        _viewModel = StateObject(wrappedValue: SportListViewModel(sportType: sportType))
        
        // Initialize analysisTemplate with a default based on sport
        let analysisKey = "analysisTemplate_\(sportType.rawValue)"
        let stored = UserDefaults.standard.string(forKey: analysisKey) ?? Match.getDefaultAnalysisTemplate(sport: sportType.rawValue)
        _analysisTemplate = State(initialValue: stored)
    }

    @State private var refreshFlag = UUID()
    @State private var showingSettings = false
    @State private var analysisTemplate: String
    private var analysisTemplateKey: String {
        "analysisTemplate_\(sportType.rawValue)"
    }

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
                            TextEditor(text: $analysisTemplate)
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
                                analysisTemplate = Match.getDefaultAnalysisTemplate(sport: sportType.rawValue)
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .navigationTitle("Editare prompt")
                    .navigationBarItems(trailing: Button("Gata") {
                        showingSettings = false
                    })
                }
                .onChange(of: analysisTemplate) {
                    UserDefaults.standard.set(analysisTemplate, forKey: analysisTemplateKey)
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
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
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
                            NavigationLink(destination: FileDetailView(fileName: file.fileName, url: APIConfig.url(for: sportType), sportsType: sportType.rawValue)) {
                                FileRow(
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
