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
    @AppStorage("isGroupSectionExpanded") private var isGroupSectionExpanded = true
    
    init(match: Match) {
        _viewModel = ObservedObject(wrappedValue: MatchBetsViewModel(match: match))
    }
    
var body: some View {
    List {
        if let bet = viewModel.bet {
            // --- Group management section ---
            Section {
                if isGroupSectionExpanded {
                    Picker("Selectează grupul", selection: $viewModel.selectedGroupKey) {
                        ForEach(Array(bet.eventGroups.keys.sorted()), id: \.self) { key in
                            Text(key).tag(key)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    HStack {
                        TextField("Nume nou grup", text: $viewModel.newGroupName)
                            .textFieldStyle(.roundedBorder)

                        Button("Adaugă") {
                            viewModel.addGroup()
                        }
                    }

                    if viewModel.selectedGroupKey != MatchBetsViewModel.defaultGroupKey {
                        Button("Șterge grupul curent", role: .destructive) {
                            viewModel.deleteCurrentGroup()
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Grupuri de pariuri")
                    Spacer()
                    Button(action: {
                        withAnimation {
                            isGroupSectionExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isGroupSectionExpanded ? "chevron.down" : "chevron.right")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
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
                            selection = .correctScore("\(viewModel.homeScore):\(viewModel.awayScore)")
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

            if let events = bet.eventGroups[viewModel.selectedGroupKey] {
                Section(header: Text("Grup: \(viewModel.selectedGroupKey)")) {
                    ForEach(events) { event in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(event.name.rawValue)
                                Text(displaySelection(event.selection))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(action: {
                                viewModel.toggleWon(for: event)
                            }) {
                                Image(systemName: iconName(for: event.won))
                                    .foregroundColor(color(for: event.won))
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                eventToDelete = event
                            } label: {
                                Label("Șterge", systemImage: "trash")
                            }
                        }
                    }
                    if !events.isEmpty {
                        Button(role: .destructive) {
                            showDeleteAllConfirmation = true
                        } label: {
                            Label("Șterge toate pariurile din \(viewModel.selectedGroupKey)", systemImage: "trash")
                        }
                        .padding(.top)
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
    // --- Swipe gesture for group switching ---
    .gesture(
        DragGesture().onEnded { value in
            if let bet = viewModel.bet {
                let keys = Array(bet.eventGroups.keys.sorted())
                if let currentIndex = keys.firstIndex(of: viewModel.selectedGroupKey) {
                    let newIndex: Int?
                    if value.translation.width < -50 {
                        newIndex = currentIndex < keys.count - 1 ? currentIndex + 1 : nil
                    } else if value.translation.width > 50 {
                        newIndex = currentIndex > 0 ? currentIndex - 1 : nil
                    } else {
                        newIndex = nil
                    }

                    if let i = newIndex {
                        viewModel.selectedGroupKey = keys[i]
                    }
                }
            }
        }
    )
}

    @ViewBuilder
    private var dynamicInput: some View {
        switch viewModel.selectedType {
        case .yesOrNo:
            Picker("Răspuns", selection: $viewModel.boolValue) {
                Text("Da").tag(true)
                Text("Nu").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
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
            HStack {
                Picker("Gazde", selection: $viewModel.homeScore) {
                    ForEach(0..<11) { Text("\($0)").tag($0) }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity)

                Text(":")
                    .font(.title)
                    .padding(.horizontal)

                Picker("Oaspeți", selection: $viewModel.awayScore) {
                    ForEach(0..<11) { Text("\($0)").tag($0) }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity)
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
    
    private func iconName(for won: Bool?) -> String {
        switch won {
        case .none:
            return "circle"
        case .some(true):
            return "checkmark.circle.fill"
        case .some(false):
            return "xmark.circle.fill"
        }
    }

    private func color(for won: Bool?) -> Color {
        switch won {
        case .none:
            return .gray
        case .some(true):
            return .green
        case .some(false):
            return .red
        }
    }
}
