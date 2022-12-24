//
//  InteractionChecker.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 24.12.22.
//

import Foundation

struct InteractionChecker {
    static func getInteractionBetween(aName: String, bName: String) -> Interaction? {
        let interactionFromAToB = getInteractionFromAToB(aName: aName, bName: bName)
        let interactionFromBToA = getInteractionFromAToB(aName: bName, bName: aName)
        if let interactionFromAToB, let interactionFromBToA {
            let isAtoB = interactionFromAToB.dangerCount >= interactionFromBToA.dangerCount
            let interactionType = isAtoB ? interactionFromAToB : interactionFromBToA
            return Interaction(
                aName: aName,
                bName: bName,
                interactionType: interactionType
            )
        } else if let interactionFromAToB {
            return Interaction(
                aName: aName,
                bName: bName,
                interactionType: interactionFromAToB
            )
        } else if let interactionFromBToA {
            return Interaction(
                aName: aName,
                bName: bName,
                interactionType: interactionFromBToA
            )
        } else {
            return nil
        }
    }

    private static func getInteractionFromAToB(
        aName: String,
        bName: String
    ) -> InteractionType? {
        guard let substanceA = SubstanceRepo.shared.getSubstance(name: aName) else {return nil}
        guard let interactions = substanceA.interactions else {return nil}
        if let substanceB = SubstanceRepo.shared.getSubstance(name: bName) {
            if (doInteractionsContainSubstance(interactions: interactions.dangerous, substance: substanceB)) {
                return InteractionType.dangerous
            } else if (doInteractionsContainSubstance(interactions: interactions.unsafe, substance: substanceB)) {
                return InteractionType.unsafe
            } else if (doInteractionsContainSubstance(interactions: interactions.uncertain, substance: substanceB)) {
                return InteractionType.uncertain
            } else {
                return nil
            }
        } else {
            if (interactions.dangerous.contains(bName)) {
                return InteractionType.dangerous
            } else if (interactions.unsafe.contains(bName)) {
                return InteractionType.unsafe
            } else if (interactions.uncertain.contains(bName)) {
                return InteractionType.uncertain
            } else {
                return nil
            }
        }
    }

    private static func doInteractionsContainSubstance(
        interactions: [String],
        substance: Substance
    ) -> Bool {
        let extendedInteractions = replaceSubstitutedAmphetaminesAndSerotoninReleasers(interactions: interactions)
        let isSubstanceInDangerClass =
        substance.categories.contains { categoryName in
            extendedInteractions.contains { interactionName in
                interactionName.localizedCaseInsensitiveContains(categoryName)
            }
        }
        let range = NSRange(location: 0, length: substance.name.utf16.count)
        let isWildCardMatch = extendedInteractions.contains { interaction in
            guard let regex = try? NSRegularExpression(pattern: interaction.replacingOccurrences(of: "x", with: "[\\S]*"), options: .caseInsensitive) else {return false}
            return regex.firstMatch(in: substance.name, options: [], range: range) != nil
        }
        return extendedInteractions.contains(substance.name) || isSubstanceInDangerClass || isWildCardMatch
    }

    private static func replaceSubstitutedAmphetaminesAndSerotoninReleasers(interactions: [String]) -> [String] {
        interactions.flatMap { name in
            switch (name) {
            case "Substituted amphetamines":
                return substitutedAmphetamines
            case "Serotonin releasers":
                return serotoninReleasers
            default:
                return [name]
            }
        }.uniqued()
    }

    private static let serotoninReleasers = [
        "MDMA",
        "MDA",
        "Mephedrone"
    ]

    private static let substitutedAmphetamines = [
        "Amphetamine",
        "Methamphetamine",
        "Ethylamphetamine",
        "Propylamphetamine",
        "Isopropylamphetamine",
        "Bromo-DragonFLY",
        "Lisdexamfetamine",
        "Clobenzorex",
        "Dimethylamphetamine",
        "Selegiline",
        "Benzphetamine",
        "Ortetamine",
        "3-Methylamphetamine",
        "4-Methylamphetamine",
        "4-MMA",
        "Xylopropamine",
        "ß-methylamphetamine",
        "3-phenylmethamphetamine",
        "2-FA",
        "2-FMA",
        "2-FEA",
        "3-FA",
        "3-FMA",
        "3-FEA",
        "Fenfluramine",
        "Norfenfluramine",
        "4-FA",
        "4-FMA",
        "4-CA",
        "4-BA",
        "4-IA",
        "DCA",
        "4-HA",
        "4-HMA",
        "3,4-DHA",
        "OMA",
        "3-MA",
        "MMMA",
        "MMA",
        "PMA",
        "PMMA",
        "PMEA",
        "4-ETA",
        "TMA-2",
        "TMA-6",
        "4-MTA",
        "5-API",
        "Cathine",
        "Phenmetrazine",
        "3-FPM",
        "Prolintane"
    ]

}

struct Interaction {
    let aName: String
    let bName: String
    let interactionType: InteractionType
}

extension Interaction: Hashable, Identifiable {
    var id: Int {
        hashValue
    }

    func hash(into hasher: inout Hasher) {
        var hash: String = interactionType.hashValue.formatted()
        if aName < bName {
            hash = hash + aName + bName
        } else {
            hash = hash + bName + aName
        }
        hasher.combine(hash)
    }
}
