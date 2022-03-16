import Foundation

extension String {
    func hasEqualMeaning(other: String) -> Bool {
        if self.caseInsensitiveCompare(other) == .orderedSame {
            return true
        }
        if "\(self)s".caseInsensitiveCompare(other) == .orderedSame {
            return true
        }
        if "\(other)s".caseInsensitiveCompare(self) == .orderedSame {
            return true
        }
        return false
    }
}
