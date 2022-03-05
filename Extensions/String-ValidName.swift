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

    var capitalizedIfNotAlready: String {
        if uppercaseLetterCount >= 2 {
            return self
        } else {
            return self.capitalized
        }
    }

    private var uppercaseLetterCount: Int {
        var result = 0
        for letter in self where letter.isUppercase {
            result += 1
        }
        return result
    }
}
