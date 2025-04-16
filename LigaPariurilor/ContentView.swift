//
//  ContentView.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 16.04.2025.
//

import SwiftUI

struct ContentView: View {
@StateObject private var viewModel = JSONViewModel()
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let content = viewModel.formattedText {
                ScrollView {
                    Text(content)
                        .padding()
                        .multilineTextAlignment(.leading)
                }
            } else if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let error = viewModel.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else {
                Text("No data loaded.")
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchJSON()
        }
    }
}

#Preview {
    ContentView()
}

class JSONViewModel: ObservableObject {
    @Published var formattedText: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchJSON() {
        guard let url = URL(string: "http://localhost:6969/files/api_response_soccer_uefa_champs_league.json") else {
            errorMessage = "Invalid URL"
            return
        }

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }

                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                    self.formattedText = String(data: prettyData, encoding: .utf8)
                } catch {
                    self.errorMessage = "Failed to parse JSON"
                }
            }
        }.resume()
    }
}
