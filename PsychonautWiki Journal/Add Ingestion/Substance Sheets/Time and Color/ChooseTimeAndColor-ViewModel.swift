import Foundation
import CoreData

extension ChooseTimeAndColor {

    class ViewModel: ObservableObject {

        @Published var selectedColor = SubstanceColor.allCases.randomElement() ?? SubstanceColor.blue
        @Published var selectedTime = Date()
        @Published var isLoadingCompanions = true
        var doesCompanionExistAlready = true
        var substance: Substance?
        var administrationRoute = AdministrationRoute.allCases.randomElement() ?? AdministrationRoute.oral
        var dose: Double = 0
        var units: String?

        func setDefaultColor() {
            let fetchRequest = SubstanceCompanion.fetchRequest()
            guard let name = substance?.name else { return }
            let companions = (try? PersistenceController.shared.viewContext.fetch(fetchRequest)) ?? []
            let maybeColor = companions.first { comp in
                comp.substanceNameUnwrapped == name
            }?.color
            if let color = maybeColor {
                doesCompanionExistAlready = true
                self.selectedColor = color
            } else {
                doesCompanionExistAlready = false
                let usedColors = companions.compactMap { comp in
                    comp.color
                }
                let otherColors = Set(SubstanceColor.allCases).subtracting(usedColors)
                self.selectedColor = otherColors.first ?? SubstanceColor.allCases.randomElement() ?? SubstanceColor.blue
            }
            isLoadingCompanions = false
        }

        func addIngestion(to experience: Experience?) {
            let context = PersistenceController.shared.viewContext
            context.performAndWait {
                if !doesCompanionExistAlready {
                    let companion = SubstanceCompanion(context: context)
                    companion.substanceName = substance?.name
                    companion.colorAsText = selectedColor.rawValue
                }
                let ingestion = Ingestion(context: context)
                ingestion.identifier = UUID()
                ingestion.time = selectedTime
                ingestion.dose = dose
                ingestion.units = units
                ingestion.administrationRoute = administrationRoute.rawValue
                ingestion.substanceName = substance?.name
                ingestion.color = selectedColor.rawValue
                ingestion.experience = experience
                try? context.save()
            }
        }
    }
}
