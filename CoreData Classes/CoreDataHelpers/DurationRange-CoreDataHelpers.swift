import Foundation

extension DurationRange {

    func oneValue(at valueFrom0To1: Double) -> TimeInterval {
        assert(valueFrom0To1 >= 0 && valueFrom0To1 <= 1)
        let difference = maxSec - minSec
        return minSec + valueFrom0To1 * difference
    }
}
