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
            FootballListPage()
                .tabItem {
                    Label("Fotbal", systemImage: "soccerball")
                }

            BasketballListPage()
                .tabItem {
                    Label("Baschet", systemImage: "basketball")
                }
        }
    }
}
