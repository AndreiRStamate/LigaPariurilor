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

            BasketballList()
                .tabItem {
                    Label("Baschet", systemImage: "basketball")
                }

            HockeyList()
                .tabItem {
                    Label("Hochei", systemImage: "hockey.puck")
                }
        }
    }
}

struct BasketballList: View {
    var body: some View {
        ZStack {
            Color.green.opacity(0.2).ignoresSafeArea()
            Text("Basketball List")
                .font(.largeTitle)
                .bold()
        }
    }
}

struct HockeyList: View {
    var body: some View {
        ZStack {
            Color.green.opacity(0.2).ignoresSafeArea()
            Text("Hockey List")
                .font(.largeTitle)
                .bold()
        }
    }
}
