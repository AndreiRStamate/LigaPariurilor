//
//  FileRowView.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 19.04.2025.
//

import SwiftUI

struct FileRow: View {
    let file: LeagueFile
    @Binding var refreshFlag: UUID
    @ObservedObject var viewModel: SportListViewModel

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
                        viewModel.refresh(fileName: file.fileName) {
                            refreshFlag = UUID()
                        }
                    }
            }
            Image(systemName: viewModel.favoriteFileNames.contains(file.fileName) ? "star.fill" : "star")
                .foregroundColor(.yellow)
                .onTapGesture {
                    viewModel.toggleFavorite(fileName: file.fileName)
                }
                .padding(.leading, 8)
        }
        .padding(.vertical, 4)
    }
}
