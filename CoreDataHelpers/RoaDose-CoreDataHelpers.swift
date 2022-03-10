import Foundation
import CoreData

extension RoaDose {

    var unitsUnwrapped: String? {
        if let unwrap = units, unwrap != "" {
            return unwrap
        }
        return nil
    }

    var thresholdUnwrapped: Double? {
        threshold == 0 ? nil : threshold
    }

    var heavyUnwrapped: Double? {
        heavy == 0 ? nil : heavy
    }

    var minAndMaxRangeForGraph: (min: Double, max: Double)? {
        if let threshold = thresholdUnwrapped, let heavy = heavyUnwrapped, threshold <= heavy {
            return (threshold, heavy)
        }
        if let threshold = thresholdUnwrapped, let strongMax = strong?.max, threshold <= strongMax {
            return (threshold, strongMax)
        }
        if let lightMin = light?.min, let heavy = heavyUnwrapped, lightMin <= heavy {
            return (lightMin, heavy)
        }
        if let lightMin = light?.min, let strongMax = strong?.max, lightMin <= strongMax {
            return (lightMin, strongMax)
        }
        return nil
    }
}
