//
//  FileListView.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 17.04.2025.
//

import SwiftUI

struct FileListView: View {

    var body: some View {
        TabView {
            SportListPage(sportType: SportType.football)
                .tabItem {
                    Label("Fotbal", systemImage: "soccerball")
                }
            SportListPage(sportType: SportType.basketball)
                .tabItem {
                    Label("Baschet", systemImage: "basketball")
                }
            SportListPage(sportType: SportType.hockey)
                .tabItem {
                    Label("Hochei", systemImage: "hockey.puck")
                }
        }
    }
}
