import Foundation
import CoreData

extension DoseRange {

    var minUnwrapped: Double? {
        min == 0 ? nil : min
    }

    var maxUnwrapped: Double? {
        max == 0 ? nil : max
    }

    var isDefined: Bool {
        minUnwrapped != nil && maxUnwrapped != nil
    }

    static func createDefault(moc: NSManagedObjectContext, addTo doseTypes: DoseTypes) -> DoseRange {
        let defaultDoseRange = DoseRange(context: moc)
        defaultDoseRange.min = 0
        defaultDoseRange.max = 0
        return defaultDoseRange
    }
}
