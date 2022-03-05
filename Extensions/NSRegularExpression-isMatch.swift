import Foundation

extension NSRegularExpression {
    func isMatch(with letters: String) -> Bool {
        let range = NSRange(location: 0, length: letters.utf16.count)
        return self.firstMatch(in: letters, options: [], range: range) != nil
    }
}
