import Foundation

extension RoaDuration {
    var isFullTimeLineDefined: Bool {
        onset?.isFullyDefined ?? false &&
        comeup?.isFullyDefined ?? false &&
        peak?.isFullyDefined ?? false &&
        offset?.isFullyDefined ?? false
    }
}
