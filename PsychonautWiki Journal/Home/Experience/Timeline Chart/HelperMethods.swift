import SwiftUI

struct HelperMethods {

    static func getEndOfGraphTime(ingestions: [Ingestion], shouldAddTimeAtEnd: Bool = true) -> Date {
        assert(!ingestions.isEmpty)

        // Initialize endOfGraphTime sensibly
        var endOfGraphTime = ingestions.first!.timeUnwrapped
        for ingestion in ingestions {
            let substance = ingestion.substanceCopy!
            let duration = substance.getDuration(for: ingestion.administrationRouteUnwrapped)!

            // Choose the latest possible offset to make sure that the graph fits all ingestions
            let offsetEnd = duration.onset!.maxSec
                + duration.comeup!.maxSec
                + duration.peak!.maxSec
                + duration.offset!.maxSec

            let maybeNewEndTime = ingestion.timeUnwrapped.addingTimeInterval(offsetEnd)
            if endOfGraphTime.distance(to: maybeNewEndTime) > 0 {
                endOfGraphTime = maybeNewEndTime
            }
        }
        if shouldAddTimeAtEnd {
            endOfGraphTime.addTimeInterval(secondsToAddAtEndOfGraph)
        }

        return endOfGraphTime
    }

    static func getLineModels(sortedIngestions: [Ingestion]) -> [IngestionLineModel] {
        assert(!sortedIngestions.isEmpty)

        let timeOfFirstIngestion = sortedIngestions.first!.timeUnwrapped
        let graphEndTime = getEndOfGraphTime(ingestions: sortedIngestions)
        let totalGraphDuration = timeOfFirstIngestion.distance(to: graphEndTime)

        var linesData = [IngestionLineModel]()
        for (verticalWeight, ingestion) in getSortedIngestionsWithVerticalWeights(for: sortedIngestions) {
            let substance = ingestion.substanceCopy!
            let duration = substance.getDuration(for: ingestion.administrationRouteUnwrapped)!
            let doseInfo = substance.getDose(for: ingestion.administrationRouteUnwrapped)
            let ingestionTime = ingestion.timeUnwrapped

            // if weight 0 we take the minimum durations and if 1 we take the maximum durations
            let horizontalWeight = getHorizontalWeight(for: ingestion.dose, doseTypes: doseInfo)
            assert(horizontalWeight >= 0 && horizontalWeight <= 1)

            let insetTimes = getInsetTimes(of: ingestion, comparedTo: sortedIngestions.prefix(while: { ing in
                ingestion != ing
            }))

            let ingestionLineModel = IngestionLineModel(
                color: ingestion.swiftUIColorUnwrapped,
                ingestionTimeOffset: timeOfFirstIngestion.distance(to: ingestionTime),
                totalGraphDuration: totalGraphDuration,
                verticalWeight: verticalWeight,
                horizontalWeight: horizontalWeight,
                durations: duration,
                insetTimes: insetTimes
            )

            linesData.append(ingestionLineModel)
        }

        return linesData
    }

    private static func getInsetTimes(of ingestion: Ingestion, comparedTo previousIngestions: [Ingestion]) -> Int {
        let durationOriginal = ingestion.substanceCopy!.getDuration(for: ingestion.administrationRouteUnwrapped)!

        let peakStartOriginal = ingestion.timeUnwrapped
            .addingTimeInterval(durationOriginal.onset!.minSec)
            .addingTimeInterval(durationOriginal.comeup!.minSec)
        let peakEndOriginal = peakStartOriginal
            .addingTimeInterval(durationOriginal.peak!.maxSec)

        var insetTimes = 0
        for previousIngestion in previousIngestions {
            let duration = previousIngestion.substanceCopy!.getDuration(
                for: previousIngestion.administrationRouteUnwrapped
            )!

            let peakStart = previousIngestion.timeUnwrapped
                .addingTimeInterval(duration.onset!.minSec)
                .addingTimeInterval(duration.comeup!.minSec)
            let peakEnd = peakStart.addingTimeInterval(duration.peak!.maxSec)

            if areRangesOverlapping(min1: peakStartOriginal, max1: peakEndOriginal, min2: peakStart, max2: peakEnd) {
                insetTimes += 1
            }
        }
        return insetTimes
    }

    private static func areRangesOverlapping(min1: Date, max1: Date, min2: Date, max2: Date) -> Bool {
        assert(min1 <= max1)
        assert(min2 <= max2)
        return min1 <= max2 && min2 <= max1
    }

    private static let secondsToAddAtEndOfGraph: TimeInterval = 60 * 60

    // This implementation is not ideal because it looks at each ingestion multiple times
    // A solution where we only iterate over ingestions once is also possible
    private static func getSortedIngestionsWithVerticalWeights(for sortedIngestions: [Ingestion])
    -> [(weight: Double, ingestion: Ingestion)] {
        assert(!sortedIngestions.isEmpty)
        var verticalWeights = [(Double, Ingestion)]()
        for ingestion in sortedIngestions {
            var allDoses = [Double]()
            for otherIngestion in sortedIngestions
            where otherIngestion.substanceCopy!.nameUnwrapped == ingestion.substanceCopy!.nameUnwrapped {
                allDoses.append(otherIngestion.dose)
            }

            let maxDose = allDoses.max()!

            var verticalWeight = 1.0
            if maxDose == 0 {
                verticalWeight = 1.0
            } else {
                verticalWeight = ingestion.dose / maxDose
            }
            assert(verticalWeight > 0 && verticalWeight <= 1)
            verticalWeights.append((verticalWeight, ingestion))
        }

        return verticalWeights
    }

    // Get value between 0 and 1
    // 0 means that ingestion dose is threshold or below
    // 1 means that ingestion dose is heavy or above
    // values in between are interpolated linearly
    private static func getHorizontalWeight(for ingestionDose: Double, doseTypes: DoseTypes?) -> Double {
        let defaultWeight = 0.5

        guard let doseTypesUnwrapped = doseTypes else { return defaultWeight }
        guard let minMax = doseTypesUnwrapped.minAndMaxRangeForGraph else { return defaultWeight }

        if ingestionDose <= minMax.min {
            return 0
        } else if ingestionDose >= minMax.max {
            return 1
        } else {
            let doseRelative = ingestionDose - minMax.min
            let rangeLength = minMax.max - minMax.min
            return doseRelative / rangeLength
        }
    }

}
