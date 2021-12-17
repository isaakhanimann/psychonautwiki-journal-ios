import Foundation
import CoreData

public class SubstancesFile: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case substances
    }

    enum DecodingError: Error {
        case notEnoughSubstancesParsed
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let throwableSubstances = try container.decode(
            [Throwable<Substance>].self,
            forKey: .substances)
        let substances = throwableSubstances.compactMap { try? $0.result.get() }
        if substances.count < 50 {
            throw DecodingError.notEnoughSubstancesParsed
        }
        // Create Interactions
        let generalInteractions = SubstancesFile.createGeneralInteractionsAndAddThemToSubstances(
            from: substances,
            context: context
        )
        self.generalInteractions = generalInteractions as NSSet
        self.addToSubstances(Set(substances) as NSSet)
    }

    // Each substance has a string array of the names of the interactions
    static private func createGeneralInteractionsAndAddThemToSubstances(
        from substances: [Substance],
        context: NSManagedObjectContext
        ) -> Set<GeneralInteraction> {
        var newGeneralInteractions = Set<GeneralInteraction>()
        for substance in substances {
            for interaction in substance.unsafeInteractionsDecoded {
                // Todo: interaction.name could also have x as wildcard
                // so fix this by matching a list and executing the if else for every substance match
                let substanceMatch = substances.first(where: {$0.nameUnwrapped == interaction.name})
                if let substanceMatchUnwrapped = substanceMatch {
                    substance.addToUnsafeSubstanceInteractions(substanceMatchUnwrapped)
                } else {
                    let doesGeneralInteractionAlreadyExist = newGeneralInteractions.contains(where: {$0.nameUnwrapped == interaction.name})
                    if !doesGeneralInteractionAlreadyExist {
                        let new = GeneralInteraction(context: context)
                        new.name = interaction.name
                        new.addToUnsafeSubstanceInteractions(substance)
                        newGeneralInteractions.insert(new)
                    }
                }
            }
            for interaction in substance.dangerousInteractionsDecoded {
                // Todo: interaction.name could also have x as wildcard
                // so fix this by matching a list and executing the if else for every substance match
                let substanceMatch = substances.first(where: {$0.nameUnwrapped == interaction.name})
                if let substanceMatchUnwrapped = substanceMatch {
                    substance.addToDangerousSubstanceInteractions(substanceMatchUnwrapped)
                } else {
                    let doesGeneralInteractionAlreadyExist = newGeneralInteractions.contains(where: {$0.nameUnwrapped == interaction.name})
                    if !doesGeneralInteractionAlreadyExist {
                        let new = GeneralInteraction(context: context)
                        new.name = interaction.name
                        new.addToDangerousSubstanceInteractions(substance)
                        newGeneralInteractions.insert(new)
                    }
                }
            }
        }
        return newGeneralInteractions
    }

    func inheritFrom(otherfile: SubstancesFile) {
        enableInteractions(basedOn: otherfile)
        enableFavorites(basedOn: otherfile)
        enableSubstances()
        updateLastUsedSubstances(basedOn: otherfile)
    }

    private func enableInteractions(basedOn oldSubstancesFile: SubstancesFile) {
        generalInteractionsUnwrapped.forEach { newInteraction in
            if let foundInteraction = oldSubstancesFile.getGeneralInteraction(
                    with: newInteraction.nameUnwrapped
            ) {
                newInteraction.isEnabled = foundInteraction.isEnabled
            } else {
                newInteraction.isEnabled = true
            }
        }
    }

    private func enableFavorites(basedOn oldSubstancesFile: SubstancesFile) {
        for oldSubstance in oldSubstancesFile.favoritesSorted {
            guard let foundSubstance = getSubstance(with: oldSubstance.nameUnwrapped) else {
                continue
            }
            foundSubstance.isFavorite = true
        }
    }

    private func enableSubstances() {
        let isEyeOpen = UserDefaults.standard.bool(forKey: PersistenceController.isEyeOpenKey)
        substancesUnwrapped.forEach { substance in
            substance.isEnabled = isEyeOpen
        }

        if !isEyeOpen {
            enableUncontrolledSubstances()
        }
    }

    func enableUncontrolledSubstances() {
        let namesOfUncontrolledSubstances = [
            "Caffeine",
            "Myristicin",
            "Choline bitartrate",
            "Citicoline"
        ]
        for name in namesOfUncontrolledSubstances {
            guard let foundSubstance = getSubstance(with: name) else {continue}
            foundSubstance.isEnabled = true
        }
    }

    private func updateLastUsedSubstances(basedOn oldSubstancesFile: SubstancesFile) {
        for oldSubstance in oldSubstancesFile.substancesUnwrapped {
            if let foundNewSubstance = getSubstance(with: oldSubstance.nameUnwrapped) {
                foundNewSubstance.lastUsedDate = oldSubstance.lastUsedDate
            }
        }
    }

    func toggleAllOn() {
        substancesUnwrapped.forEach { substance in
            substance.isEnabled = true
        }
        generalInteractionsUnwrapped.forEach { interaction in
            interaction.isEnabled = true
        }
    }

    func toggleAllControlledOff() {
        substancesUnwrapped.forEach { substance in
            substance.isEnabled = false
        }
        generalInteractionsUnwrapped.forEach { interaction in
            interaction.isEnabled = false
        }
        enableUncontrolledSubstances()
    }

}
