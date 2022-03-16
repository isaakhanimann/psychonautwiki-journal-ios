import Foundation

extension String {
    var validClassName: String {
        var result = self.replacingOccurrences(of: "_", with: " ").capitalizedIfNotAlready
        if !result.hasSuffix("s") {
            result.append(contentsOf: "s")
        }
        return result
    }

    var removeGreekLetters: String {
        let alpha = "Α"
        let regularA = "A"
        let beta = "Β"
        let regularB = "B"
        var result = self.replacingOccurrences(of: alpha, with: regularA)
        result = result.replacingOccurrences(of: beta, with: regularB)
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
