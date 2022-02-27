import SwiftUI

struct HorizontalScaleView<Content: View>: View {

    @ViewBuilder var content: Content

    @State private var scale: Double = 1

    var body: some View {
        VStack {
            GeometryReader { geo in
                ScrollView(.horizontal) {
                    content
                        .frame(width: scale * geo.size.width, height: geo.size.height)
                }
            }
            Slider(value: $scale, in: 1...10)
        }
    }
}

struct HorizontalScaleView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalScaleView {
            ZStack {
                Rectangle()
                    .fill(Color.red)
                Capsule()
                    .fill(Color.green)
            }
        }
    }
}
