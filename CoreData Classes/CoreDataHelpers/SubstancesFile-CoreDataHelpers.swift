import Foundation

extension SubstancesFile {

    var creationDateUnwrapped: Date {
        creationDate ?? Date()
    }

    var generalInteractionsUnwrapped: [GeneralInteraction] {
        generalInteractions?.allObjects as? [GeneralInteraction] ?? []
    }

    var generalInteractionsUnwrappedSorted: [GeneralInteraction] {
        generalInteractionsUnwrapped.sorted { gen1, gen2 in
            gen1.nameUnwrapped < gen2.nameUnwrapped
        }
    }

    var substancesUnwrapped: [Substance] {
        substances?.allObjects as? [Substance] ?? []
    }

    var favoritesSorted: [Substance] {
        let favorites = enabledSubstancesUnwrapped.filter { substance in
            substance.isFavorite
        }
        return favorites.sorted { sub1, sub2 in
            sub1.nameUnwrapped < sub2.nameUnwrapped
        }
    }

    func getRecentlyUsedSubstancesInOrder(maxSubstancesToGet: Int) -> [Substance] {
        let substancesSortedByUse = enabledSubstancesUnwrapped.sorted { sub1, sub2 in
            guard let sub1DateUnwrapped = sub1.lastUsedDate else { return false }
            guard let sub2DateUnwrapped = sub2.lastUsedDate else { return true }

            return sub1DateUnwrapped > sub2DateUnwrapped
        }
        var recentlyUsed = [Substance]()
        let subset = substancesSortedByUse[..<min(maxSubstancesToGet, substancesSortedByUse.count)]
        for substances in subset where substances.lastUsedDate != nil {
            recentlyUsed.append(substances)
        }
        return recentlyUsed
    }

    func getAllOkInteractionsSorted(showAllInteractions: Bool) -> [GeneralInteraction] {
        let okInteractionNames: Set = [
            "alcohol",
            "antihistamine",
            "diphenhydramine",
            "grapefruit",
            "hormonal birth control",
            "snris",
            "serotonin",
            "selective serotonin reuptake inhibitor",
            "tricyclic antidepressants"
        ]

        if showAllInteractions {
            return generalInteractionsUnwrappedSorted
        } else {
            return generalInteractionsUnwrappedSorted.filter { interaction in
                okInteractionNames.contains(interaction.nameUnwrapped.lowercased())
            }
        }
    }

    var enabledSubstancesUnwrapped: [Substance] {
        substancesUnwrapped.filter { substance in
            substance.isEnabled
        }
    }

    func getGeneralInteraction(with name: String) -> GeneralInteraction? {
        let lowerCaseName = name.lowercased()
        return generalInteractionsUnwrapped.first { interaction in
            interaction.nameUnwrapped.lowercased() == lowerCaseName
        }
    }

    func getSubstance(with name: String) -> Substance? {
        let lowerCaseName = name.lowercased()
        return substancesUnwrapped.first { substance in
            substance.nameUnwrapped.lowercased() == lowerCaseName
        }
    }
}
