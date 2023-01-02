import CoreData
import UIKit

func playHapticFeedback() {
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    impactMed.impactOccurred()
}

func getCurrentAppVersion() -> String {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
}


let namesOfUncontrolledSubstances = [
    "Caffeine",
    "Myristicin",
    "Choline Bitartrate",
    "Citicoline"
]

func getColor(for substanceName: String) -> SubstanceColor {
    let fetchRequest = SubstanceCompanion.fetchRequest()
    fetchRequest.fetchLimit = 1
    fetchRequest.predicate = NSPredicate(
        format: "substanceName = %@", substanceName
    )
    let maybeColor = try? PersistenceController.shared.viewContext.fetch(fetchRequest).first?.color
    return maybeColor ?? SubstanceColor.purple
}
