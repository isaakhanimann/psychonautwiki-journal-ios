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

        // Create Categories and add substances
        let categories = SubstancesFile.createAndFillCategories(from: substances, context: context)

        // Create Interactions
        let generalInteractions = SubstancesFile.createGeneralInteractionsAndAddThemToSubstances(
            from: categories,
            context: context
        )

        self.categories = categories as NSSet
        self.generalInteractions = generalInteractions as NSSet
    }

    static private func createAndFillCategories(
        from substances: [Substance],
        context: NSManagedObjectContext
    ) -> Set<Category> {
        var addedCategories = Set<Category>()
        var substancesWithoutCategory = [Substance]()
        for substance in substances {
            if substance.categoriesDecoded.isEmpty {
                substancesWithoutCategory.append(substance)
            } else {
                for categoryDecoded in substance.categoriesDecoded {

                    let maybeFirstCategory = addedCategories.first { addedCategory in
                        addedCategory.nameUnwrapped.lowercased() == categoryDecoded.lowercased()
                    }

                    if let existingCategory = maybeFirstCategory {
                        existingCategory.addToSubstances(substance)
                    } else {
                        let newCategory = Category(context: context)
                        newCategory.name = categoryDecoded
                        newCategory.addToSubstances(substance)
                        addedCategories.insert(newCategory)
                    }
                }
            }
        }
        if !substancesWithoutCategory.isEmpty {
            let newCategory = Category(context: context)
            newCategory.name = "No Category"

            for subst in substancesWithoutCategory {
                newCategory.addToSubstances(subst)
            }
            addedCategories.insert(newCategory)
        }

        return addedCategories
    }

    // Each substance has a string array of the names of the interactions
    static private func createGeneralInteractionsAndAddThemToSubstances(
        from categories: Set<Category>,
        context: NSManagedObjectContext
        ) -> Set<GeneralInteraction> {

        var allSubstances = Set<Substance>()
        for category in categories {
            allSubstances = allSubstances.union(category.substancesUnwrapped)
        }

        var newGeneralInteractions = Set<GeneralInteraction>()

        for substance in allSubstances {
            for interaction in substance.unsafeInteractionsDecoded {
                SubstancesFile.findAndAddMatchOrAddToGeneralInteractions(
                    unsafeOrDangerous: .unsafe,
                    substanceToAdd: substance,
                    toSubstancesIn: categories,
                    matching: interaction,
                    context: context,
                    generalInteractions: &newGeneralInteractions
                )
            }

            for interaction in substance.dangerousInteractionsDecoded {
                SubstancesFile.findAndAddMatchOrAddToGeneralInteractions(
                    unsafeOrDangerous: .dangerous,
                    substanceToAdd: substance,
                    toSubstancesIn: categories,
                    matching: interaction,
                    context: context,
                    generalInteractions: &newGeneralInteractions
                )
            }
        }

        return newGeneralInteractions
    }

    private enum UnsafeOrDangerous {
        case unsafe, dangerous
    }

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_parameter_count
    // swiftlint:disable function_body_length
    static private func findAndAddMatchOrAddToGeneralInteractions(
        unsafeOrDangerous: UnsafeOrDangerous,
        substanceToAdd: Substance,
        toSubstancesIn categories: Set<Category>,
        matching decodedInteraction: Substance.DecodedInteraction,
        context: NSManagedObjectContext,
        generalInteractions: inout Set<GeneralInteraction>
    ) {
        // Try to match category
        let firstCategoryMatch = categories.first { category in
            decodedInteraction.name.lowercased() == category.nameUnwrapped.lowercased()
        }
        if let foundCategory = firstCategoryMatch {
            for substanceInCategory in foundCategory.substancesUnwrapped {
                switch unsafeOrDangerous {
                case .unsafe:
                    substanceInCategory.addToUnsafeSubstanceInteractions(substanceToAdd)
                case .dangerous:
                    substanceInCategory.addToDangerousSubstanceInteractions(substanceToAdd)
                }
            }
            return
        }

        // Try to match substance exact
        var allSubstances = Set<Substance>()
        for category in categories {
            allSubstances = allSubstances.union(category.substancesUnwrapped)
        }
        let firstSubstanceMatch = allSubstances.first { substance2 in
            decodedInteraction.name.lowercased() == substance2.nameUnwrapped.lowercased()
        }
        if let foundSubstance = firstSubstanceMatch {
            switch unsafeOrDangerous {
            case .unsafe:
                foundSubstance.addToUnsafeSubstanceInteractions(substanceToAdd)
            case .dangerous:
                foundSubstance.addToDangerousSubstanceInteractions(substanceToAdd)
            }
            return
        }

        // Try to match substance with x wildcard
        let regexString = decodedInteraction.name.lowercased().replacingOccurrences(of: "x", with: "*")
        if let regex = try? NSRegularExpression(pattern: regexString, options: [.caseInsensitive]) {
            let matchingSubstances = allSubstances.filter { substance in
                let range = NSRange(location: 0, length: substance.nameUnwrapped.utf16.count)
                return regex.firstMatch(in: substance.nameUnwrapped, options: [], range: range) != nil
            }
            if !matchingSubstances.isEmpty {
                for matchingSubstance in matchingSubstances {
                    switch unsafeOrDangerous {
                    case .unsafe:
                        matchingSubstance.addToUnsafeSubstanceInteractions(substanceToAdd)
                    case .dangerous:
                        matchingSubstance.addToDangerousSubstanceInteractions(substanceToAdd)
                    }
                }
                return
            }
        }

        // Try to match general interaction
        let firstGeneralMatch = generalInteractions.first { generalInteraction in
            generalInteraction.nameUnwrapped.lowercased() == decodedInteraction.name.lowercased()
        }
        if let foundGeneral = firstGeneralMatch {
            switch unsafeOrDangerous {
            case .unsafe:
                foundGeneral.addToUnsafeSubstanceInteractions(substanceToAdd)
            case .dangerous:
                foundGeneral.addToDangerousSubstanceInteractions(substanceToAdd)
            }
        } else {
            let newGeneralInteraction = GeneralInteraction(context: context)
            newGeneralInteraction.name = decodedInteraction.name
            newGeneralInteraction.isEnabled = true
            switch unsafeOrDangerous {
            case .unsafe:
                newGeneralInteraction.addToUnsafeSubstanceInteractions(substanceToAdd)
            case .dangerous:
                newGeneralInteraction.addToDangerousSubstanceInteractions(substanceToAdd)
            }
            generalInteractions.insert(newGeneralInteraction)
        }

    }
}
