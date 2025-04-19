//
//  DateFormatter.swift
//  LigaPariurilor
//
//  Created by Andrei R Stamate on 18.04.2025.
//

import Foundation

private let isoFormatter = ISO8601DateFormatter()
private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter
}()
private let fullFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd-MM-yyyy HH:mm"
    return formatter
}()
private let appCalendar = Calendar.current

public func formattedDate(_ isoString: String) -> String {
    guard let date = isoFormatter.date(from: isoString) else {
        return isoString
    }
    if appCalendar.isDateInToday(date) {
        return "Azi la \(timeFormatter.string(from: date))"
    } else if appCalendar.isDateInTomorrow(date) {
        return "Mâine la \(timeFormatter.string(from: date))"
    } else {
        return fullFormatter.string(from: date)
    }
}
