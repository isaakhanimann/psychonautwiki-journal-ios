import SwiftUI

struct DurationView: View {

    let duration: RoaDuration?
    let lineWidth: CGFloat = 3
    var isTotalOrAfterglowDefined: Bool {
        duration?.total?.displayString != nil
        || duration?.afterglow?.displayString != nil
    }

    var body: some View {
        if isTotalOrAfterglowDefined {
            VStack(alignment: .leading, spacing: 0) {
                if let total = duration?.total?.displayString {
                    Text("Total Duration: \(total)")
                }
                if let afterglow = duration?.afterglow?.displayString {
                    Text("After effects: \(afterglow)")
                }
            }
            .font(.footnote)
        } else {
            EmptyView()
        }
    }
}
