import Foundation

public extension String {
    var htmlStripped: String {

        var htmlStripped = self

        htmlStripped = htmlStripped.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)

        htmlStripped = htmlStripped.replacingOccurrences(of: "&nbsp;", with: " ")

        htmlStripped = htmlStripped.replacingOccurrences(of: "&amp;", with: "&")

        htmlStripped = htmlStripped.replacingOccurrences(of: "&quot;", with: "\"")

        htmlStripped = htmlStripped.replacingOccurrences(of: "&#39;", with: "'")

        htmlStripped = htmlStripped.replacingOccurrences(of: "&lt;", with: "<")

        htmlStripped = htmlStripped.replacingOccurrences(of: "&gt;", with: ">")

        return htmlStripped
    }
}
