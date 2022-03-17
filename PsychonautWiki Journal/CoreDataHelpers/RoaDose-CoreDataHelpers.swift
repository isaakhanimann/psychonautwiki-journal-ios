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
        if let threshOrLightMinUnwrap = threshOrLightMin,
           threshOrLightMinUnwrap >= dose {
            return .thresh
        } else if let threshOrLightMinUnwrap = threshOrLightMin,
                  let lightMaxOrCommonMinUnwrap = lightMaxOrCommonMin,
                  dose >= threshOrLightMinUnwrap && dose <= lightMaxOrCommonMinUnwrap {
            return .light
        } else if let lightMaxOrCommonMinUnwrap = lightMaxOrCommonMin,
                  let commonMaxOrStrongMinUnwrap = commonMaxOrStrongMin,
                  dose >= lightMaxOrCommonMinUnwrap && dose <= commonMaxOrStrongMinUnwrap {
            return .common
        } else if let commonMaxOrStrongMinUnwrap = commonMaxOrStrongMin,
                  let strongMaxOrHeavyUnwrap = strongMaxOrHeavy,
                  dose >= commonMaxOrStrongMinUnwrap && dose <= strongMaxOrHeavyUnwrap {
            return .strong
        } else if let strongMaxOrHeavyUnwrap = strongMaxOrHeavy,
                  dose >= strongMaxOrHeavyUnwrap {
            return .heavy
        } else {
            return .none
        }
    }

    var threshOrLightMin: Double? {
        if let thresh = thresholdUnwrapped {
            return thresh
        } else {
            return light?.minUnwrapped
        }
    }

    var lightMaxOrCommonMin: Double? {
        if let lightMax = light?.maxUnwrapped {
            return lightMax
        } else {
            return common?.minUnwrapped
        }
    }

    var commonMaxOrStrongMin: Double? {
        if let commonMax = common?.maxUnwrapped {
            return commonMax
        } else {
            return strong?.minUnwrapped
        }
    }

    var strongMaxOrHeavy: Double? {
        if let strongMax = strong?.maxUnwrapped {
            return strongMax
        } else {
            return heavyUnwrapped
        }
    }
}
