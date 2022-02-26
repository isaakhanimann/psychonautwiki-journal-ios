import Foundation
import CoreData

extension RoaDose {

    var thresholdUnwrapped: Double? {
        threshold == 0 ? nil : threshold
    }

    var lightUnwrapped: RoaRange? {
        guard let lightUn = light else {
            return nil
        }
        guard lightUn.isDefined else {
            return nil
        }
        return light
    }

    var commonUnwrapped: RoaRange? {
        guard let commonUn = light else {
            return nil
        }
        guard commonUn.isDefined else {
            return nil
        }
        return common
    }

    var strongUnwrapped: RoaRange? {
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
}
