import Foundation

extension String {
    var validClassName: String {
        var result = self.replacingOccurrences(of: "_", with: " ")
        if result != result.uppercased() {
            result = result.capitalized
        }
        if !result.hasSuffix("s") {
            result.append(contentsOf: "s")
        }
        return result
    }
}
