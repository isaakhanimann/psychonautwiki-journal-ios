import SwiftUI

struct DurationView: View {

    let duration: RoaDuration?

    let lineWidth: CGFloat = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let total = duration?.total?.displayString {
                Text("Total: \(total)")
            }
            if let afterglow = duration?.afterglow?.displayString {
                Text("After effects: \(afterglow)")
            }
            HStack(alignment: .top, spacing: 0) {
                VStack {
                    CurveBottom()
                        .stroke(.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    Text(duration?.onset?.displayString ?? "")
                }
                VStack {
                    CurveUp()
                        .stroke(.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    Text(" \(duration?.comeup?.displayString ?? "") ")
                }
                VStack {
                    CurveTop()
                        .stroke(.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    Text(duration?.peak?.displayString ?? "")
                }
                VStack {
                    CurveDown()
                        .stroke(.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    Text(" \(duration?.offset?.displayString ?? "") ")
                }
            }
            .frame(height: 70)
        }
        .font(.footnote)
    }
}

struct DurationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                let duration = PreviewHelper.shared.getSubstance(with: "Caffeine")!.roasUnwrapped.first!.duration!
                Section {
                    DurationView(duration: duration)
                        .previewDevice(PreviewDevice(rawValue: "iPhone 13 mini"))
                }
            }
        }
    }
}
