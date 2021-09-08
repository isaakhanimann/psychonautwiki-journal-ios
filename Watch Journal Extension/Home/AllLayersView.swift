import SwiftUI

struct AllLayersView: View {

    let watchFaceModel: WatchFaceModel

    init(ingestions: [Ingestion]) {
        self.watchFaceModel = WatchFaceModel(ingestions: ingestions)
    }

    var body: some View {
        GeometryReader { geometry in
            let squareLength = min(geometry.size.width, geometry.size.height)
            let radius = squareLength / 2
            let lineWidth = min(radius / CGFloat(watchFaceModel.layers.count), 20)

            ZStack {
                ForEach(0..<watchFaceModel.layers.count) { layerIndex in
                    let layer = watchFaceModel.layers[layerIndex]
                    let halfLineWidth = lineWidth/2
                    let insetPerSide = halfLineWidth + CGFloat(layerIndex) * lineWidth
                    OneLayerView(
                        layer: layer,
                        lineWidth: lineWidth
                    )
                    .padding(insetPerSide)
                }
            }
            .frame(width: squareLength, height: squareLength)
        }
    }
}

struct AllLayersView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        AllLayersView(ingestions: helper.experiences.first!.sortedIngestionsUnwrapped)
    }
}
