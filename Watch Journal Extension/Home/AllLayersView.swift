import SwiftUI

struct AllLayersView: View {

    let watchFaceModel: WatchFaceModel

    init(ingestions: [Ingestion]) {
        self.watchFaceModel = WatchFaceModel(ingestions: ingestions)
    }

    var body: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2
            let lineWidth = min(radius / CGFloat(watchFaceModel.layers.count), 20)

            ZStack {
                ForEach(0..<watchFaceModel.layers.count) { layerIndex in
                    let layer = watchFaceModel.layers[layerIndex]
                    let halfLineWidth = lineWidth/2
                    let insetOneSide = halfLineWidth + CGFloat(layerIndex) * lineWidth
                    OneLayerView(
                        layer: layer,
                        lineWidth: lineWidth,
                        layerInsetPerSide: insetOneSide
                    )
                }
            }
        }
    }
}

struct AllLayersView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        AllLayersView(ingestions: helper.experiences.first!.sortedIngestionsUnwrapped)
    }
}
