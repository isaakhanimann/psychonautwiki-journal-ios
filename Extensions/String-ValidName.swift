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

    var capitalizedSubstanceName: String {
        if uppercaseLetterCount >= 3 {
            return self
        } else {
            return self.capitalized
        }
    }

    private var uppercaseLetterCount: Int {
        var result = 0
        for letter in self {
            if letter.isUppercase {
                result += 1
            }
        }
        return result
    }
}
