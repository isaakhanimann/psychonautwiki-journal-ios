import Foundation
import CoreData

public class SubstancesFile: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case substances
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

        // Create Categories and add substances
        let categories = SubstancesFile.createAndFillCategories(from: substances, context: context)

        // Create Interactions
        let generalInteractions = SubstancesFile.addSubstanceAndCategoryInteractionsAndReturnNewGeneralInteractions(
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
                        addedCategory.nameUnwrapped == categoryDecoded
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

    // swiftlint:disable function_body_length
    static private func addSubstanceAndCategoryInteractionsAndReturnNewGeneralInteractions(
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

                // Try to find category
                let firstCategoryMatch = categories.first { category in
                    interaction.name == category.nameUnwrapped
                }
                if let foundCategory = firstCategoryMatch {
                    substance.addToUnsafeCategoryInteractions(foundCategory)
                    continue
                }

                // Try to find substance
                let firstSubstanceMatch = allSubstances.first { substance2 in
                    interaction.name == substance2.nameUnwrapped
                }
                if let foundSubstance = firstSubstanceMatch {
                    substance.addToUnsafeSubstanceInteractions(foundSubstance)
                    continue
                }

                // Try to find general interaction
                let firstGeneralMatch = newGeneralInteractions.first { generalInteraction in
                    generalInteraction.name == interaction.name
                }
                if let foundGeneral = firstGeneralMatch {
                    substance.addToUnsafeGeneralInteractions(foundGeneral)
                } else {
                    let newGeneralInteraction = GeneralInteraction(context: context)
                    newGeneralInteraction.name = interaction.name
                    substance.addToUnsafeGeneralInteractions(newGeneralInteraction)
                    newGeneralInteractions.insert(newGeneralInteraction)
                }
            }

            for interaction in substance.dangerousInteractionsDecoded {

                // Try to find category
                let firstCategoryMatch = categories.first { category in
                    interaction.name == category.nameUnwrapped
                }
                if let foundCategory = firstCategoryMatch {
                    substance.addToDangerousCategoryInteractions(foundCategory)
                    continue
                }

                // Try to find substance
                let firstSubstanceMatch = allSubstances.first { substance2 in
                    interaction.name == substance2.nameUnwrapped
                }
                if let foundSubstance = firstSubstanceMatch {
                    substance.addToDangerousSubstanceInteractions(foundSubstance)
                    continue
                }

                // Try to find general interaction
                let firstGeneralMatch = newGeneralInteractions.first { generalInteraction in
                    generalInteraction.name == interaction.name
                }
                if let foundGeneral = firstGeneralMatch {
                    substance.addToDangerousGeneralInteractions(foundGeneral)
                } else {
                    let newGeneralInteraction = GeneralInteraction(context: context)
                    newGeneralInteraction.name = interaction.name
                    substance.addToDangerousGeneralInteractions(newGeneralInteraction)
                    newGeneralInteractions.insert(newGeneralInteraction)
                }
            }
        }

        return newGeneralInteractions
    }
}
