import Foundation
import CoreData

struct RoaDuration: Decodable {

    let onset: DurationRange?
    let comeup: DurationRange?
    let peak: DurationRange?
    let offset: DurationRange?
    let total: DurationRange?
    let afterglow: DurationRange?

    enum CodingKeys: String, CodingKey {
        case onset, comeup, peak, offset, total, afterglow
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.onset = try? container.decodeIfPresent(DurationRange.self, forKey: .onset)
        self.comeup = try? container.decodeIfPresent(DurationRange.self, forKey: .comeup)
        self.peak = try? container.decodeIfPresent(DurationRange.self, forKey: .peak)
        self.offset = try? container.decodeIfPresent(DurationRange.self, forKey: .offset)
        self.total = try? container.decodeIfPresent(DurationRange.self, forKey: .total)
        self.afterglow = try? container.decodeIfPresent(DurationRange.self, forKey: .afterglow)
    }

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
