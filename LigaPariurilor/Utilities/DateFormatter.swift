//
//  DateFormatter.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 18.04.2025.
//

import SwiftUI

public func formattedDate(_ isoString: String) -> String {
    if let date = ISO8601DateFormatter().date(from: isoString) {
        let calendar = Calendar.current
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        if calendar.isDateInToday(date) {
            return "Azi la \(timeFormatter.string(from: date))"
        } else if calendar.isDateInTomorrow(date) {
            return "Mâine la \(timeFormatter.string(from: date))"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy HH:mm"
            return formatter.string(from: date)
        }
    }
    return isoString
}
