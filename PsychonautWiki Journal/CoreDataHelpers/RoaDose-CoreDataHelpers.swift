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

    func getRangeType(for dose: Double, with doseUnits: String) -> DoseRangeType {
        guard self.units == doseUnits else {return .none}
        if let thresh = thresholdUnwrapped,
           thresh >= dose {
            return .thresh
        } else if let lightMin = light?.minUnwrapped,
                  let lightMax = light?.maxUnwrapped,
                  dose >= lightMin && dose <= lightMax {
            return .light
        } else if let commonMin = common?.minUnwrapped,
                  let commonMax = common?.maxUnwrapped,
                  dose >= commonMin && dose <= commonMax {
            return .common
        } else if let strongMin = strong?.minUnwrapped,
                  let strongMax = strong?.maxUnwrapped,
                  dose >= strongMin && dose <= strongMax {
            return .strong
        } else if let heavyOrStrongMax = heavyUnwrapped ?? strong?.maxUnwrapped,
                  dose >= heavyOrStrongMax {
            return .heavy
        } else {
            return .none
        }
    }
}
