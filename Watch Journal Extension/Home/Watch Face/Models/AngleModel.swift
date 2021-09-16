import SwiftUI

struct AngleModel: Identifiable {

    // swiftlint:disable identifier_name
    let id = UUID()
    let ingestionPoint: Angle
    let onsetStart: Angle
    let peakStart: Angle
    let peakEnd: Angle
    let offsetEnd: Angle
    let color: Color

    var min: Angle {
        ingestionPoint
    }

    var max: Angle {
        offsetEnd
    }

    init?(ingestion: Ingestion) {
        guard let durations = ingestion.substanceCopy?
                .getDuration(for: ingestion.administrationRouteUnwrapped) else {return nil}
        let weight = ingestion.horizontalWeight

        guard let onsetMin = durations.onset?.minSec else {return nil}
        guard let onsetMiddle = durations.onset?.oneValue(at: 0.5) else {return nil}
        guard let comeupMiddle = durations.comeup?.oneValue(at: 0.5) else {return nil}
        guard let peakMiddle = durations.peak?.oneValue(at: weight) else {return nil}
        guard let offsetMax = durations.offset?.maxSec else {return nil}

        let ingestionTime = ingestion.timeUnwrapped
        let onsetStartTime = ingestionTime.addingTimeInterval(onsetMin)
        let averageOnsetStartTime = ingestionTime.addingTimeInterval(onsetMiddle)
        let peakStartTime = averageOnsetStartTime.addingTimeInterval(comeupMiddle)
        let peakEndTime = peakStartTime.addingTimeInterval(peakMiddle)
        let offsetEndTime = peakEndTime.addingTimeInterval(offsetMax)

        self.ingestionPoint = AngleModel.getAngle(from: ingestionTime)
        self.onsetStart = AngleModel.getAngle(from: onsetStartTime)
        self.peakStart = AngleModel.getAngle(from: peakStartTime)
        self.peakEnd = AngleModel.getAngle(from: peakEndTime)
        self.offsetEnd = AngleModel.getAngle(from: offsetEndTime)
        self.color = ingestion.swiftUIColorUnwrapped
    }

    static func getAngle(from date: Date) -> Angle {
        let calendar = Calendar.current

        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)

        let timeInSeconds = TimeInterval(hour * 60 * 60 + minute * 60 + second)
        let secondsInClock: TimeInterval = 43200

        return Angle(degrees: timeInSeconds / secondsInClock * 360)
    }
}
