import Foundation
import CoreData

struct RoaDose: Decodable {

    let units: String?
    let threshold: Double?
    let light: RoaRange?
    let common: RoaRange?
    let strong: RoaRange?
    let heavy: Double?

    var minAndMaxRangeForGraph: (min: Double, max: Double)? {
        if let thresholdUnwrap = threshold, let heavyUnwrap = heavy, thresholdUnwrap <= heavyUnwrap {
            return (thresholdUnwrap, heavyUnwrap)
        }
        if let thresholdUnwrap = threshold, let strongMax = strong?.max, thresholdUnwrap <= strongMax {
            return (thresholdUnwrap, strongMax)
        }
        if let lightMin = light?.min, let heavyUnwrap = heavy, lightMin <= heavyUnwrap {
            return (lightMin, heavyUnwrap)
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
        if let thresh = threshold {
            return thresh
        } else {
            return light?.min
        }
    }

    var lightMaxOrCommonMin: Double? {
        if let lightMax = light?.max {
            return lightMax
        } else {
            return common?.min
        }
    }

    var commonMaxOrStrongMin: Double? {
        if let commonMax = common?.max {
            return commonMax
        } else {
            return strong?.min
        }
    }

    var strongMaxOrHeavy: Double? {
        if let strongMax = strong?.max {
            return strongMax
        } else {
            return heavy
        }
    }
}
