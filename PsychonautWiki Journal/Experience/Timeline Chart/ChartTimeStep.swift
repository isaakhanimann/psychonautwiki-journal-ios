import Foundation

enum ChartTimeStep: TimeInterval {
    case halfHour = 1800
    case oneHour = 3600
    case twoHours = 7200
    case threeHours = 10800

    func inSeconds() -> TimeInterval {
        self.rawValue
    }
}
