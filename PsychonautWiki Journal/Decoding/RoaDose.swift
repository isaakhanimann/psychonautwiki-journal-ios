import Foundation
import CoreData

struct RoaDose: Decodable {

    let units: String
    let lightMin: Double?
    let commonMin: Double?
    let strongMin: Double?
    let heavyMin: Double?

    func getRangeType(for dose: Double, with doseUnits: String) -> DoseRangeType {
        guard self.units == doseUnits else {return .none}
        if let threshOrLightMinUnwrap = lightMin,
           threshOrLightMinUnwrap >= dose {
            return .thresh
        } else if let lightMinUnwrap = lightMin,
                  let commonMinUnwrap = commonMin,
                  dose >= lightMinUnwrap && dose <= commonMinUnwrap {
            return .light
        } else if let commonMinUnwrap = commonMin,
                  let strongMinUnwrap = strongMin,
                  dose >= commonMinUnwrap && dose <= strongMinUnwrap {
            return .common
        } else if let strongMinUnwrap = strongMin,
                  let heavyMinUnwrap = heavyMin,
                  dose >= strongMinUnwrap && dose <= heavyMinUnwrap {
            return .strong
        } else if let heavyMinUnwrap = heavyMin,
                  dose >= heavyMinUnwrap {
            return .heavy
        } else {
            return .none
        }
    }
}
