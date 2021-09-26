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

    var categoriesUnwrapped: [Category] {
        categories?.allObjects as? [Category] ?? []
    }

    var categoriesUnwrappedSorted: [Category] {
        categoriesUnwrapped.sorted { cat1, cat2 in
            cat1.nameUnwrapped < cat2.nameUnwrapped
        }
    }

    var favoritesSorted: [Substance] {
        let favorites = allEnabledSubstancesUnwrapped.filter { substance in
            substance.isFavorite
        }
        return favorites.sorted { sub1, sub2 in
            sub1.nameUnwrapped < sub2.nameUnwrapped
        }
    }

    func getRecentlyUsedSubstancesInOrder(maxSubstancesToGet: Int) -> [Substance] {
        let substancesSortedByUse = allEnabledSubstancesUnwrapped.sorted { sub1, sub2 in
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

    var allSubstancesUnwrapped: [Substance] {
        SubstancesFile.getAllSubstances(of: categoriesUnwrapped)
    }

    var allEnabledSubstancesUnwrapped: [Substance] {
        SubstancesFile.getAllSubstances(of: categoriesUnwrapped).filter { substance in
            substance.isEnabled
        }
    }

    func getGeneralInteraction(with name: String) -> GeneralInteraction? {
        let lowerCaseName = name.lowercased()
        return generalInteractionsUnwrapped.first { interaction in
            interaction.nameUnwrapped.lowercased() == lowerCaseName
        }
    }

    func getCategory(with name: String) -> Category? {
        let lowerCaseName = name.lowercased()
        return categoriesUnwrapped.first { category in
            category.nameUnwrapped.lowercased() == lowerCaseName
        }
    }

    func getSubstance(with name: String) -> Substance? {
        let lowerCaseName = name.lowercased()
        return allSubstancesUnwrapped.first { substance in
            substance.nameUnwrapped.lowercased() == lowerCaseName
        }
    }

    var sortedCategoriesUnwrapped: [Category] {
        categoriesUnwrapped.sorted { cat1, cat2 in
            cat1.nameUnwrapped < cat2.nameUnwrapped
        }
    }

    static func getAllSubstances(of categories: [Category]) -> [Substance] {
        var allSubstances = [Substance]()
        for category in categories {
            allSubstances.append(contentsOf: category.substancesUnwrapped)
        }
        return allSubstances.uniqued()
    }
}
