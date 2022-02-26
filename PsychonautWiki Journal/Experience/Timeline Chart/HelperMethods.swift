import SwiftUI

struct HelperMethods {

    static func getLineModels(sortedIngestions: [Ingestion]) -> [IngestionLineModel] {
        guard let timeOfFirstIngestion = sortedIngestions.first?.timeUnwrapped else {return []}
        guard let graphEndTime = Experience.getEndTime(for: sortedIngestions) else {return []}
        let totalGraphDuration = timeOfFirstIngestion.distance(to: graphEndTime)

        var linesData = [IngestionLineModel]()
        for (verticalWeight, ingestion) in getSortedIngestionsWithVerticalWeights(for: sortedIngestions) {
            guard let substance = ingestion.substance else {continue}
            guard let duration = substance.getDuration(for: ingestion.administrationRouteUnwrapped) else {continue}
            let ingestionTime = ingestion.timeUnwrapped

            // if weight 0 we take the minimum durations and if 1 we take the maximum durations
            let horizontalWeight = ingestion.horizontalWeight
            assert(horizontalWeight >= 0 && horizontalWeight <= 1)

            let insetTimes = getInsetTimes(of: ingestion, comparedTo: sortedIngestions.prefix(while: { ing in
                ingestion != ing
            }))

            guard let ingestionLineModel = IngestionLineModel(
                color: ingestion.swiftUIColorUnwrapped,
                ingestionTimeOffset: timeOfFirstIngestion.distance(to: ingestionTime),
                totalGraphDuration: totalGraphDuration,
                verticalWeight: verticalWeight,
                horizontalWeight: horizontalWeight,
                durations: duration,
                insetTimes: insetTimes
            ) else {continue}

            linesData.append(ingestionLineModel)
        }

        return linesData
    }

    private static func getInsetTimes(of ingestion: Ingestion, comparedTo previousIngestions: [Ingestion]) -> Int {
        let defaultInset = 0
        guard let durationOriginal = ingestion.substance?.getDuration(
                for: ingestion.administrationRouteUnwrapped
        ) else {return defaultInset}

        guard let onset = durationOriginal.onset?.oneValue(at: 0.5) else {return defaultInset}
        guard let comeup = durationOriginal.comeup?.oneValue(at: 0.5) else {return defaultInset}
        guard let peak = durationOriginal.peak?.oneValue(at: ingestion.horizontalWeight) else {return defaultInset}

        let peakStartOriginal = ingestion.timeUnwrapped.addingTimeInterval(onset + comeup)
        let peakEndOriginal = peakStartOriginal.addingTimeInterval(peak)

        var insetTimes = 0
        for previousIngestion in previousIngestions {
            guard let duration = previousIngestion.substance?.getDuration(
                for: previousIngestion.administrationRouteUnwrapped
            ) else {continue}

            guard let onset = duration.onset?.oneValue(at: 0.5) else {continue}
            guard let comeup = duration.comeup?.oneValue(at: 0.5) else {continue}
            guard let peak = duration.peak?.oneValue(at: ingestion.horizontalWeight) else {continue}

            let peakStart = previousIngestion.timeUnwrapped.addingTimeInterval(onset + comeup)
            let peakEnd = peakStart.addingTimeInterval(peak)

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

    // This implementation is not ideal because it looks at each ingestion multiple times
    // A solution where we only iterate over ingestions once is also possible
    private static func getSortedIngestionsWithVerticalWeights(for sortedIngestions: [Ingestion])
    -> [(weight: Double, ingestion: Ingestion)] {
        assert(!sortedIngestions.isEmpty)
        var verticalWeights = [(Double, Ingestion)]()
        for ingestion in sortedIngestions {
            var allDoses = [Double]()
            for otherIngestion in sortedIngestions
            where otherIngestion.substanceName == ingestion.substanceName {
                allDoses.append(otherIngestion.dose)
            }

            let maxDose = allDoses.max() ?? 0

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
}
