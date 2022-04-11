import Foundation

extension RoaDuration {

    var maxLengthOfTimelineInSec: TimeInterval? {
        let total = total?.maxSec
        guard let onset = onset?.maxSec else {return total}
        guard let comeup = comeup?.maxSec else {return total}
        guard let peak = peak?.maxSec else {return total}
        guard let offset = offset?.maxSec else {return total}
        return onset
            + comeup
            + peak
            + offset
    }

    var isFullTimeLineDefined: Bool {
        onset?.isFullyDefined ?? false &&
        comeup?.isFullyDefined ?? false &&
        peak?.isFullyDefined ?? false &&
        offset?.isFullyDefined ?? false
    }
}
