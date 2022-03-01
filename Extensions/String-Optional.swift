import Foundation

extension String {
    var optionalIfEmpty: String? {
        if self.isEmpty {
            return nil
        } else {
            return self
        }
    }
}
