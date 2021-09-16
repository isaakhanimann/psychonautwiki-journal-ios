import Foundation
import CoreData

public class SubstanceCopy: NSManagedObject {

    convenience init?(basedOn substance: Substance, context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = substance.name
        self.url = substance.url

        var roaCopies = Set<Roa>()
        for roa in substance.roasUnwrapped {
            let roaCopy = Roa(context: context)
            roaCopy.name = roa.name

            let doseTypesCopy = DoseTypes(context: context)
            if let doseTypes = roa.doseTypes {
                doseTypesCopy.threshold = doseTypes.threshold
                doseTypesCopy.heavy = doseTypes.heavy
                doseTypesCopy.units = doseTypes.units ?? "mg"
                doseTypesCopy.light = SubstanceCopy.getDoseRangeCopy(basedOn: doseTypes.light, context: context)
                doseTypesCopy.common = SubstanceCopy.getDoseRangeCopy(basedOn: doseTypes.common, context: context)
                doseTypesCopy.strong = SubstanceCopy.getDoseRangeCopy(basedOn: doseTypes.strong, context: context)
            }
            roaCopy.doseTypes = doseTypesCopy

            let durationTypesCopy = DurationTypes(context: context)
            guard let durationTypes = roa.durationTypes else {return nil}
            guard let onset = durationTypes.onset else {return nil}
            guard let comeup = durationTypes.comeup else {return nil}
            guard let peak = durationTypes.peak else {return nil}
            guard let offset = durationTypes.offset else {return nil}

            durationTypesCopy.onset = SubstanceCopy.getDurationRangeCopy(
                basedOn: onset,
                context: context
            )
            durationTypesCopy.comeup = SubstanceCopy.getDurationRangeCopy(
                basedOn: comeup,
                context: context
            )
            durationTypesCopy.peak = SubstanceCopy.getDurationRangeCopy(
                basedOn: peak,
                context: context
            )
            durationTypesCopy.offset = SubstanceCopy.getDurationRangeCopy(
                basedOn: offset,
                context: context
            )
            roaCopy.durationTypes = durationTypesCopy

            roaCopies.insert(roaCopy)
        }
        self.roas = roaCopies as NSSet
    }

    private static func getDoseRangeCopy(basedOn doseRange: DoseRange?, context: NSManagedObjectContext) -> DoseRange? {
        let newRange = DoseRange(context: context)
        newRange.min = doseRange?.min ?? 0
        newRange.max = doseRange?.max ?? 0
        return newRange
    }

    private static func getDurationRangeCopy(
        basedOn durationRange: DurationRange,
        context: NSManagedObjectContext
    ) -> DurationRange {
        let newRange = DurationRange(context: context)
        newRange.minSec = durationRange.minSec
        newRange.maxSec = durationRange.maxSec
        return newRange
    }

}
