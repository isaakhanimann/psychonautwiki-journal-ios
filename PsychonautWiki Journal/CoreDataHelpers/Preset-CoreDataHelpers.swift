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
    }

    private var substances: [Substance] {
        componentsUnwrapped.compactMap { com in
            com.substance
        }.uniqued()
    }
}
