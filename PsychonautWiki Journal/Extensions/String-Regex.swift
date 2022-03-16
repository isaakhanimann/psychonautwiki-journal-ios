import Foundation

extension String {
    func getRegexWithxAsWildcard() throws -> NSRegularExpression {
        var regex = self.lowercased().replacingOccurrences(of: "x", with: "(.*)")
        regex = "\\A" + regex + "\\Z"
        return try NSRegularExpression(pattern: regex, options: [.caseInsensitive])
    }
}
