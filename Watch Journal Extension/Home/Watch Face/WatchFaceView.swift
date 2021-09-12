import SwiftUI

struct WatchFaceView: View {

    let watchFaceModel: WatchFaceModel
    let clockHandStyle: ClockHands.ClockHandStyle
    let timeStyle: TimeStyle

    init(
        ingestions: [Ingestion],
        clockHandStyle: ClockHands.ClockHandStyle,
        timeStyle: TimeStyle
    ) {
        self.watchFaceModel = WatchFaceModel(ingestions: ingestions)
        self.clockHandStyle = clockHandStyle
        self.timeStyle = timeStyle
    }

    enum TimeStyle {
        case currentTime
        case providedTime(time: Date)
    }

    var body: some View {
        GeometryReader { geometry in
            let squareLength = min(geometry.size.width, geometry.size.height)
            let radius = squareLength / 2
            let lineWidth = min(radius / CGFloat(watchFaceModel.layers.count), 20)

            ZStack {
                ForEach(watchFaceModel.layers) { layer in
                    let halfLineWidth = lineWidth/2
                    let insetPerSide = halfLineWidth + CGFloat(layer.index) * lineWidth
                    OneLayerView(
                        layer: layer,
                        lineWidth: lineWidth
                    )
                    .padding(insetPerSide)
                }

                switch timeStyle {
                case .currentTime:
                    TimeObserverView(style: clockHandStyle)
                case .providedTime(let time):
                    ClockHands(timeToDisplay: time, style: clockHandStyle)
                }

            }
            .frame(width: squareLength, height: squareLength)
        }
    }
}

struct AllLayersView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        WatchFaceView(
            ingestions: helper.experiences.first!.sortedIngestionsUnwrapped,
            clockHandStyle: .hourAndMinute,
            timeStyle: .currentTime
        )
    }
}
