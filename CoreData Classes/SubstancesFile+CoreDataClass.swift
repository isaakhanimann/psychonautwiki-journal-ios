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
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let throwableSubstances = try container.decode(
            [Throwable<Substance>].self,
            forKey: .substances)
        let substances = throwableSubstances.compactMap { try? $0.result.get() }
        if substances.count < 50 {
            throw DecodingError.notEnoughSubstancesParsed
        }
        let psychoactiveClasses = SubstancesFile.createAndFillCategories(from: substances, context: context)
        SubstancesFile.createGeneralInteractionsAndAddThemToSubstances(
            from: psychoactiveClasses,
            context: context
        )
        self.init(context: context)
        self.psychoactiveClasses = psychoactiveClasses as NSSet
    }

    static private func createAndFillCategories(
        from substances: [Substance],
        context: NSManagedObjectContext
    ) -> Set<PsychoactiveClass> {
        var psychoactives = Set<PsychoactiveClass>()
        var substancesWithoutCategory = [Substance]()
        for substance in substances {
            if substance.categoriesDecoded.isEmpty {
                substancesWithoutCategory.append(substance)
            } else {
                for categoryDecoded in substance.categoriesDecoded {

                    let maybeFirstCategory = psychoactives.first { cat in
                        cat.nameUnwrapped.lowercased() == categoryDecoded.lowercased()
                    }

                    if let existingCategory = maybeFirstCategory {
                        existingCategory.addToSubstances(substance)
                    } else {
                        let newCategory = PsychoactiveClass(context: context)
                        newCategory.name = categoryDecoded
                        newCategory.addToSubstances(substance)
                        psychoactives.insert(newCategory)
                    }
                }
            }
        }
        if !substancesWithoutCategory.isEmpty {
            let newCategory = PsychoactiveClass(context: context)
            newCategory.name = "No Class"

            for subst in substancesWithoutCategory {
                newCategory.addToSubstances(subst)
            }
            psychoactives.insert(newCategory)
        }

        return psychoactives
    }

    // Each substance has a string array of the names of the interactions
    static private func createGeneralInteractionsAndAddThemToSubstances(
        from categories: Set<PsychoactiveClass>,
        context: NSManagedObjectContext
        ) {

        var allSubstances = Set<Substance>()
        for category in categories {
            allSubstances = allSubstances.union(category.substancesUnwrapped)
        }

        var newGeneralInteractions = Set<UnresolvedInteraction>()

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
        toSubstancesIn categories: Set<PsychoactiveClass>,
        matching decodedInteraction: Substance.DecodedInteraction,
        context: NSManagedObjectContext,
        generalInteractions: inout Set<UnresolvedInteraction>
    ) {
        // Try to match category
        let firstCategoryMatch = categories.first { category in
            decodedInteraction.name.lowercased() == category.nameUnwrapped.lowercased()
        }
        if let foundCategory = firstCategoryMatch {
            for substanceInCategory in foundCategory.substancesUnwrapped {
                switch unsafeOrDangerous {
                case .unsafe:
                    substanceInCategory.addToUnsafeSubstances(substanceToAdd)
                case .dangerous:
                    substanceInCategory.addToDangerousSubstances(substanceToAdd)
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
                foundSubstance.addToUnsafeSubstances(substanceToAdd)
            case .dangerous:
                foundSubstance.addToDangerousSubstances(substanceToAdd)
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
                        matchingSubstance.addToUnsafeSubstances(substanceToAdd)
                    case .dangerous:
                        matchingSubstance.addToDangerousSubstances(substanceToAdd)
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
                foundGeneral.addToUnsafeSubstances(substanceToAdd)
            case .dangerous:
                foundGeneral.addToDangerousSubstances(substanceToAdd)
            }
        } else {
            let newGeneralInteraction = UnresolvedInteraction(context: context)
            newGeneralInteraction.name = decodedInteraction.name
            switch unsafeOrDangerous {
            case .unsafe:
                newGeneralInteraction.addToUnsafeSubstances(substanceToAdd)
            case .dangerous:
                newGeneralInteraction.addToDangerousSubstances(substanceToAdd)
            }
            generalInteractions.insert(newGeneralInteraction)
        }

    }

    static let namesOfUncontrolledSubstances = [
        "Caffeine",
        "Myristicin",
        "Choline bitartrate",
        "Citicoline"
    ]
}
