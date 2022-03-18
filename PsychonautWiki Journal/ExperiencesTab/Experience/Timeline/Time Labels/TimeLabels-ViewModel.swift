import Foundation

extension TimeLabels {

    struct Label: Identifiable {
        let xOffset: Double
        let text: String
        // swiftlint:disable identifier_name
        var id: Double {
            xOffset
        }
    }

    class ViewModel {

        let labels: [Label]

        init?(
            startTime: Date,
            endTime: Date,
            totalWidth: Double
        ) {
            let timeDifference = startTime.distance(to: endTime)
            guard timeDifference != 0 else {return nil}
            let differenceInHours = timeDifference/(60*60)
            let hourSteps = Int(ceil(differenceInHours/15))
            let dates = Self.getDates(from: startTime, to: endTime, hourSteps: hourSteps)
            labels = dates.map { date in
                Self.getLabel(for: date, startTime: startTime, timeDifference: timeDifference, totalWidth: totalWidth)
            }
        }

        static func getLabel(
            for date: Date,
            startTime: Date,
            timeDifference: TimeInterval,
            totalWidth: Double
        ) -> Label {
            let fraction = startTime.distance(to: date) / timeDifference
            assert(fraction >= 0 && fraction <= 1)
            let xOffset = fraction * totalWidth
            var hour = Calendar.current.component(.hour, from: date)
            if hour == 0 {
                hour = 24
            }
            return Label(xOffset: xOffset, text: String(hour))
        }

        static func getDates(from startTime: Date, to endTime: Date, hourSteps: Int) -> [Date] {
            guard let firstDate = startTime.nearestFullHourInTheFuture() else {return []}
            let hourStepsInSec: TimeInterval = Double(hourSteps)*60*60
            var fullHours = [Date]()
            var checkTime = firstDate
            while checkTime < endTime {
                fullHours.append(checkTime)
                checkTime = checkTime.addingTimeInterval(hourStepsInSec)
            }
            return fullHours
        }
    }
}
