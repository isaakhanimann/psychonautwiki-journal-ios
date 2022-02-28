import SwiftUI

struct DurationView: View {

    let duration: RoaDuration?

    let lineWidth: CGFloat = 3

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack {
                CurveBottom()
                    .stroke(.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                Text("\(duration?.onset?.displayString ?? "") ")
            }
            VStack {
                CurveUp()
                    .stroke(.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                Text(" \(duration?.comeup?.displayString ?? "") ")
            }
            VStack {
                CurveTop()
                    .stroke(.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                Text(" \(duration?.peak?.displayString ?? "") ")
            }
            VStack {
                CurveDown()
                    .stroke(.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                Text(" \(duration?.offset?.displayString ?? "")")
            }
            VStack {
                CurveBottom()
                    .stroke(.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                Text("\(duration?.afterglow?.displayString ?? "") ")
            }
        }
        .font(.footnote)
        .frame(height: 100)
    }
}

struct DurationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                let duration = PreviewHelper().getSubstance(with: "Caffeine")!.roasUnwrapped.first!.duration!
                Section {
                    DurationView(duration: duration)
                        .previewDevice(PreviewDevice(rawValue: "iPhone 13 mini"))
                }
            }
        }
    }
}
