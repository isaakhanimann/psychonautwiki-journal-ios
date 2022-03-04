import Foundation

extension String {
    var validClassName: String {
        var result = self.replacingOccurrences(of: "_", with: " ")
        result = result.capitalized
        if !result.hasSuffix("s") {
            result.append(contentsOf: "s")
        }
        return result
    }
}
