import Foundation
import CoreData

public class Substance: NSManagedObject, Decodable {

    // These variables are intermediately stored
    // such that they can be used in SubstancesFile to create objects and relationships
    var decodedUncertainNames = [String]()
    var decodedUnsafeNames = [String]()
    var decodedDangerousNames = [String]()
    var decodedPsychoactiveNames = [String]()
    var decodedChemicalNames = [String]()
    var decodedEffects = [DecodedEffect]()
    var decodedCrossToleranceNames = [String]()

    static let noClassName = "Miscellaneous"

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            fatalError("Missing managed object context")
        }
        let substanceDecoder = try SubstanceDecoder(decoder: decoder)
        let name = try substanceDecoder.getName()
        self.init(context: context) // init needs to be called after calls that can throw an exception
        self.name = name
        self.url = substanceDecoder.getURL()
        self.decodedEffects = substanceDecoder.getEffects()
        self.roas = substanceDecoder.getRoas()
        self.tolerance = substanceDecoder.getTolerance()
        self.addictionPotential = substanceDecoder.getAddictionPotential()
        self.toxicity = substanceDecoder.getToxicity()
        self.decodedCrossToleranceNames = substanceDecoder.getToleranceNames()
        self.decodedDangerousNames = substanceDecoder.getDangerousInteractions()
        self.decodedUnsafeNames = substanceDecoder.getUnsafeInteractions()
        self.decodedUncertainNames = substanceDecoder.getUncertainInteractions()
        let psychoactiveNames = substanceDecoder.getPsychoactiveNames()
        self.decodedPsychoactiveNames = psychoactiveNames
        self.firstPsychoactiveName = psychoactiveNames.first ?? Self.noClassName
        let chemicalNames = substanceDecoder.getChemicalNames()
        self.decodedChemicalNames = chemicalNames
        self.firstChemicalName = chemicalNames.first ?? Self.noClassName
    }
}
