import Foundation

enum InteractionChecker {

    static func getUnsafeIngestions(
        of substance: Substance,
        with previousIngestions: [Ingestion]
    ) -> [Ingestion] {
        previousIngestions.filter { ingestion in
            substance.unsafeSubstanceInteractionsUnwrapped.contains { unsafeSubstance in
                unsafeSubstance.nameUnwrapped == ingestion.substanceCopy!.nameUnwrapped
            }
        }
    }

    static func getDangerousIngestions(
        of substance: Substance,
        with previousIngestions: [Ingestion]
    ) -> [Ingestion] {
        previousIngestions.filter { ingestion in
            substance.dangerousSubstanceInteractionsUnwrapped.contains { dangerousSubstance in
                dangerousSubstance.nameUnwrapped == ingestion.substanceCopy!.nameUnwrapped
            }
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
