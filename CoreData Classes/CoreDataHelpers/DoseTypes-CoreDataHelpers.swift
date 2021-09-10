import Foundation
import CoreData

extension DoseTypes {

    var thresholdUnwrapped: Double? {
        threshold == 0 ? nil : threshold
    }

    var lightUnwrapped: DoseRange? {
        guard let lightUn = light else {
            return nil
        }
        guard lightUn.isDefined else {
            return nil
        }
        return light
    }

    var commonUnwrapped: DoseRange? {
        guard let commonUn = light else {
            return nil
        }
        guard commonUn.isDefined else {
            return nil
        }
        return common
    }

    var strongUnwrapped: DoseRange? {
        guard let strongUn = strong else {
            return nil
        }
        guard strongUn.isDefined else {
            return nil
        }
        return strong
    }

    var heavyUnwrapped: Double? {
        heavy == 0 ? nil : heavy
    }

    var minAndMaxRangeForGraph: (min: Double, max: Double)? {
        if let threshold = thresholdUnwrapped, let heavy = heavyUnwrapped, threshold <= heavy {
            return (threshold, heavy)
        }
        if let threshold = thresholdUnwrapped, let strongMax = strongUnwrapped?.max, threshold <= strongMax {
            return (threshold, strongMax)
        }
        if let lightMin = lightUnwrapped?.min, let heavy = heavyUnwrapped, lightMin <= heavy {
            return (lightMin, heavy)
        }
        if let lightMin = lightUnwrapped?.min, let strongMax = strongUnwrapped?.max, lightMin <= strongMax {
            return (lightMin, strongMax)
        }
        return nil
    }

    static func createDefault(moc: NSManagedObjectContext) -> DoseTypes {
        let defaultDoses = DoseTypes(context: moc)
        defaultDoses.units = "mg"
        defaultDoses.threshold = 0
        defaultDoses.light = DoseRange.createDefault(moc: moc, addTo: defaultDoses)
        defaultDoses.common = DoseRange.createDefault(moc: moc, addTo: defaultDoses)
        defaultDoses.strong = DoseRange.createDefault(moc: moc, addTo: defaultDoses)
        defaultDoses.heavy = 0
        return defaultDoses
    }
}
