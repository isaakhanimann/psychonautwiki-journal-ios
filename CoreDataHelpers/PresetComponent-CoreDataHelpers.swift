import Foundation
import CoreData

extension PresetComponent {

    var substanceNameUnwrapped: String {
        substanceName ?? "Unknown"
    }

    var administrationRouteUnwrapped: AdministrationRoute? {
        AdministrationRoute(rawValue: administrationRoute ?? "")
    }

    var unitsUnwrapped: String {
        units ?? ""
    }

    var dosePerUnitOfPresetUnwrapped: Double? {
        if dosePerUnitOfPreset == 0 {
            return nil
        } else {
            return dosePerUnitOfPreset
        }
    }

    var substance: Substance? {
        guard let substanceNameUnwrapped = substanceName else {return nil}
        let fetchRequest: NSFetchRequest<Substance> = Substance.fetchRequest()
        let pred = NSPredicate(format: "name == %@", substanceNameUnwrapped)
        fetchRequest.predicate = pred
        return try? self.managedObjectContext?.fetch(fetchRequest).first
    }
}
