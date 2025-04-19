//
//  FilenameTrimmer.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 19.04.2025.
//

extension String {
    var trimmedFilename: String {
        return self
            .replacingOccurrences(of: "api_response_", with: "")
            .replacingOccurrences(of: ".json", with: "")
    }
}
