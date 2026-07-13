//
//  Int+Extension.swift
//  Components
//
//  Created by Gabriel Gonçalves Guimarães on 10/07/26.
//
import Foundation

public extension Int {
    var asRelativeTimeString: String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
