import SwiftUI

struct DurationView: View {

    let duration: RoaDuration?
    let lineWidth: CGFloat = 3
    var isTotalOrAfterglowDefined: Bool {
        duration?.total?.displayString != nil
        || duration?.afterglow?.displayString != nil
    }
    var isPartOfCurveDefined: Bool {
        duration?.onset?.displayString != nil
        || duration?.comeup?.displayString != nil
        || duration?.peak?.displayString != nil
        || duration?.offset?.displayString != nil
    }

    var body: some View {
        if isTotalOrAfterglowDefined || isPartOfCurveDefined {
            VStack(alignment: .leading, spacing: 0) {
                if let total = duration?.total?.displayString {
                    Text("Total: \(total)")
                }
                if let afterglow = duration?.afterglow?.displayString {
                    Text("After effects: \(afterglow)")
                }
                if isPartOfCurveDefined {
                    HStack(alignment: .top, spacing: 0) {
                        VStack {
                            CurveBottom()
                                .stroke(.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                            Text(duration?.onset?.displayString ?? " ")
                        }
                        VStack {
                            CurveUp()
                                .stroke(.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                            Text(" \(duration?.comeup?.displayString ?? "") ")
                        }
                        VStack {
                            CurveTop()
                                .stroke(.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                            Text(duration?.peak?.displayString ?? " ")
                        }
                        VStack {
                            CurveDown()
                                .stroke(.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                            Text(" \(duration?.offset?.displayString ?? "") ")
                        }
                    }
                    .frame(height: 70)
                }
            }
            .font(.footnote)
        } else {
            EmptyView()
        }
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
