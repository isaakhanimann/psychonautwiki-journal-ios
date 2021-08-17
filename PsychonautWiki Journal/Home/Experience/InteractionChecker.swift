import Foundation

enum InteractionChecker {

    static func getUnsafeIngestions(
        of substance: Substance,
        with previousIngestions: [Ingestion]
    ) -> [Ingestion] {
        previousIngestions.filter { ingestion in
            substance.unsafeSubstanceInteractionsUnwrapped.contains(ingestion.substance!) ||
                substance.unsafeCategoryInteractionsUnwrapped.contains(ingestion.substance!.category!)
        }
    }

    static func getDangerousIngestions(
        of substance: Substance,
        with previousIngestions: [Ingestion]
    ) -> [Ingestion] {
        previousIngestions.filter { ingestion in
            let ingSubstance = ingestion.substance!
            return substance.dangerousSubstanceInteractionsUnwrapped.contains(ingSubstance) ||
                substance.dangerousCategoryInteractionsUnwrapped.contains(ingSubstance.category!)
        }
    }

    static func getUnsafeInteraction(of substance: Substance) -> [GeneralInteraction] {
        substance.unsafeGeneralInteractionsUnwrapped.filter { interaction in
            interaction.isEnabled
        }
    }

    static func getDangerousInteraction(of substance: Substance) -> [GeneralInteraction] {
        substance.dangerousGeneralInteractionsUnwrapped.filter { interaction in
            interaction.isEnabled
        }
    }
}
