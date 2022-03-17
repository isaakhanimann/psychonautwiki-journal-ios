import Foundation
import Algorithms

extension Preset {

    var nameUnwrapped: String {
        name ?? "Unknown"
    }

    var unitsUnwrapped: String {
        units ?? "Unknown"
    }

    var componentsUnwrapped: [PresetComponent] {
        components?.allObjects as? [PresetComponent] ?? []
    }

    var dangerousInteractions: [(Substance, Substance)] {
        substances.combinations(ofCount: 2).compactMap { combo in
            guard let first = combo[safe: 0] else {return nil}
            guard let second = combo[safe: 1] else {return nil}
            if first.isDangerous(with: second) {
                return (first, second)
            } else {
                return nil
            }
        }
        .uniqued { elem in
            elem.0.nameUnwrapped + elem.1.nameUnwrapped
        }
    }

    var unsafeInteractions: [(Substance, Substance)] {
        substances.combinations(ofCount: 2).compactMap { combo in
            guard let first = combo[safe: 0] else {return nil}
            guard let second = combo[safe: 1] else {return nil}
            if first.isUnsafe(with: second) {
                return (first, second)
            } else {
                return nil
            }
        }
        .uniqued { elem in
            elem.0.nameUnwrapped + elem.1.nameUnwrapped
        }
    }

    var uncertainInteractions: [(Substance, Substance)] {
        substances.combinations(ofCount: 2).compactMap { combo in
            guard let first = combo[safe: 0] else {return nil}
            guard let second = combo[safe: 1] else {return nil}
            if first.isUncertain(with: second) {
                return (first, second)
            } else {
                return nil
            }
        }
        .uniqued { elem in
            elem.0.nameUnwrapped + elem.1.nameUnwrapped
        }
    }

    var substances: [Substance] {
        componentsUnwrapped.compactMap { com in
            com.substance
        }.uniqued()
    }

    var dangerousPsychoactives: [PsychoactiveClass] {
        var psychoactives: Set<PsychoactiveClass> = []
        for substance in substances {
            psychoactives.formUnion(substance.dangerousPsychoactivesToShow)
        }
        return Array(psychoactives).sorted()
    }

    var unsafePsychoactives: [PsychoactiveClass] {
        var psychoactives: Set<PsychoactiveClass> = []
        for substance in substances {
            psychoactives.formUnion(substance.unsafePsychoactivesToShow)
        }
        return Array(psychoactives).sorted()
    }

    var uncertainPsychoactives: [PsychoactiveClass] {
        var psychoactives: Set<PsychoactiveClass> = []
        for substance in substances {
            psychoactives.formUnion(substance.uncertainPsychoactivesToShow)
        }
        return Array(psychoactives).sorted()
    }

    var dangerousChemicals: [ChemicalClass] {
        var chemicals: Set<ChemicalClass> = []
        for substance in substances {
            chemicals.formUnion(substance.dangerousChemicalsToShow)
        }
        return Array(chemicals).sorted()
    }

    var unsafeChemicals: [ChemicalClass] {
        var chemicals: Set<ChemicalClass> = []
        for substance in substances {
            chemicals.formUnion(substance.unsafeChemicalsToShow)
        }
        return Array(chemicals).sorted()
    }

    var uncertainChemicals: [ChemicalClass] {
        var chemicals: Set<ChemicalClass> = []
        for substance in substances {
            chemicals.formUnion(substance.uncertainChemicalsToShow)
        }
        return Array(chemicals).sorted()
    }

    var dangerousUnresolveds: [UnresolvedInteraction] {
        var unresolveds: Set<UnresolvedInteraction> = []
        for substance in substances {
            unresolveds.formUnion(substance.dangerousUnresolvedsToShow)
        }
        return Array(unresolveds).sorted()
    }

    var unsafeUnresolveds: [UnresolvedInteraction] {
        var unresolveds: Set<UnresolvedInteraction> = []
        for substance in substances {
            unresolveds.formUnion(substance.unsafeUnresolvedsToShow)
        }
        return Array(unresolveds).sorted()
    }

    var uncertainUnresolveds: [UnresolvedInteraction] {
        var unresolveds: Set<UnresolvedInteraction> = []
        for substance in substances {
            unresolveds.formUnion(substance.uncertainUnresolvedsToShow)
        }
        return Array(unresolveds).sorted()
    }

    var dangerousSubstances: [Substance] {
        var substanceInteractions: Set<Substance> = []
        for substance in substances {
            substanceInteractions.formUnion(substance.dangerousSubstancesToShow)
        }
        return Array(substanceInteractions).sorted()
    }

    var unsafeSubstances: [Substance] {
        var substanceInteractions: Set<Substance> = []
        for substance in substances {
            substanceInteractions.formUnion(substance.unsafeSubstancesToShow)
        }
        return Array(substanceInteractions).sorted()
    }

    var uncertainSubstances: [Substance] {
        var substanceInteractions: Set<Substance> = []
        for substance in substances {
            substanceInteractions.formUnion(substance.uncertainSubstancesToShow)
        }
        return Array(substanceInteractions).sorted()
    }

    var hasDangerousInteractionsToShow: Bool {
        !dangerousSubstances.isEmpty ||
        !dangerousChemicals.isEmpty ||
        !dangerousPsychoactives.isEmpty ||
        !dangerousUnresolveds.isEmpty
    }

    var hasUnsafeInteractionsToShow: Bool {
        !unsafeSubstances.isEmpty ||
        !unsafeChemicals.isEmpty ||
        !unsafePsychoactives.isEmpty ||
        !unsafeUnresolveds.isEmpty
    }

    var hasUncertainInteractionsToShow: Bool {
        !uncertainSubstances.isEmpty ||
        !uncertainChemicals.isEmpty ||
        !uncertainPsychoactives.isEmpty ||
        !uncertainUnresolveds.isEmpty
    }
}
