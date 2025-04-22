//
//  MatchBetsView.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 22.04.2025.
//

import SwiftUI

struct MatchBetsView: View {
    @ObservedObject private var viewModel: MatchBetsViewModel
    @State private var eventToDelete: BetEvent?
    @State private var showDeleteAllConfirmation = false
    @AppStorage("isCreateSectionExpanded") private var isCreateSectionExpanded = true
    
    init(match: Match) {
        _viewModel = ObservedObject(wrappedValue: MatchBetsViewModel(match: match))
    }
    
var body: some View {
    List {
        if let bet = viewModel.bet {
            Section {
                if isCreateSectionExpanded {
                    Picker("Tip pariu", selection: $viewModel.selectedName) {
                        ForEach(BetEventName.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    .onChange(of: viewModel.selectedName) {
                        viewModel.updateTypeIfInvalid()
                    }

                    Picker("Tip selecție", selection: $viewModel.selectedType) {
                        ForEach(viewModel.validTypesForSelectedName, id: \.self) { type in
                            Text(labelFor(type)).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    dynamicInput

                    Button("Adaugă pariu") {
                        let selection: BetSelection
                        switch viewModel.selectedType {
                        case .yesOrNo:
                            selection = .yesOrNo(viewModel.boolValue)
                        case .underOrOver:
                            selection = .underOrOver(viewModel.bound, viewModel.value)
                        case .chance3:
                            selection = .chance3(viewModel.chanceOption)
                        case .doubleChance3:
                            selection = .doubleChance3(viewModel.doubleChanceOption)
                        case .correctScore:
                            selection = .correctScore(viewModel.score)
                        }

                        let event = BetEvent(name: viewModel.selectedName, type: viewModel.selectedType, selection: selection)
                        viewModel.addEvent(event)
                    }
                }
            } header: {
                HStack {
                    Text("Adaugă pariu personalizat")
                    Spacer()
                    Button(action: {
                        withAnimation {
                            isCreateSectionExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isCreateSectionExpanded ? "chevron.down" : "chevron.right")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }

            Section(header: Text("Pariuri active")) {
                ForEach(bet.events) { event in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(event.name.rawValue)
                            Text(displaySelection(event.selection))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: {
                            eventToDelete = event
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }

                if !bet.events.isEmpty {
                    Button(role: .destructive) {
                        showDeleteAllConfirmation = true
                    } label: {
                        Label("Șterge toate pariurile", systemImage: "trash")
                    }
                }
            }
        } else {
            Text("Se încarcă pariul...")
        }
    }
    .alert(item: $eventToDelete) { event in
        Alert(
            title: Text("Șterge pariu"),
            message: Text("Ești sigur că vrei să ștergi acest pariu?"),
            primaryButton: .destructive(Text("Șterge")) {
                viewModel.deleteEvent(event)
            },
            secondaryButton: .cancel(Text("Anulează"))
        )
    }
    .alert("Șterge toate pariurile", isPresented: $showDeleteAllConfirmation) {
        Button("Șterge", role: .destructive) {
            viewModel.deleteAllEvents()
        }
        Button("Anulează", role: .cancel) { }
    } message: {
        Text("Ești sigur că vrei să ștergi toate pariurile?")
    }
    .navigationTitle("Lista pariurilor")
    .navigationBarTitleDisplayMode(.inline)
}

    @ViewBuilder
    private var dynamicInput: some View {
        switch viewModel.selectedType {
        case .yesOrNo:
            Toggle("Da?", isOn: $viewModel.boolValue)
        case .underOrOver:
            HStack {
                Picker("Direcție", selection: $viewModel.bound) {
                    Text("Peste").tag(BetSelection.Bound.over)
                    Text("Sub").tag(BetSelection.Bound.under)
                }.pickerStyle(SegmentedPickerStyle())
                TextField("Valoare", value: $viewModel.value, format: .number)
                    .textFieldStyle(.roundedBorder)
            }
        case .chance3:
            Picker("1X2", selection: $viewModel.chanceOption) {
                ForEach(BetSelection.Chance3Option.allCases, id: \.self) {
                    Text($0.rawValue).tag($0)
                }
            }
        case .doubleChance3:
            Picker("Șansă dublă", selection: $viewModel.doubleChanceOption) {
                ForEach(BetSelection.DoubleChanceOption.allCases, id: \.self) {
                    Text($0.rawValue).tag($0)
                }
            }
        case .correctScore:
            Picker("Scor corect", selection: $viewModel.score) {
                ForEach(["0:0", "1:0", "0:1", "1:1", "2:1", "1:2", "2:2"], id: \.self) { score in
                    Text(score).tag(score)
                }
            }
        }
    }

    private func displaySelection(_ selection: BetSelection) -> String {
        switch selection {
        case .yesOrNo(let value):
            return value ? "Da" : "Nu"
        case .underOrOver(let bound, let value):
            return "\(bound == .over ? "Peste" : "Sub") \(value)"
        case .chance3(let option):
            return option.rawValue
        case .doubleChance3(let option):
            return option.rawValue
        case .correctScore(let score):
            return score
        }
    }

    private func labelFor(_ type: BetType) -> String {
        switch type {
        case .yesOrNo: return "Da/Nu"
        case .underOrOver: return "Peste/Sub"
        case .chance3: return "1X2"
        case .doubleChance3: return "Șansă dublă"
        case .correctScore: return "Scor corect"
        }
    }
}
