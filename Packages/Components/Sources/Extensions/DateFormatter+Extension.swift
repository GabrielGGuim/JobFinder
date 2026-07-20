//
//  DateFormatter+Extension.swift
//  Components
//
//  Created by Gabriel Gonçalves Guimarães on 16/07/26.
//

import Foundation

public extension DateFormatter {
    
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
}
