import SwiftUI

struct OneLayerView: View {

    let layer: WatchFaceModel.Layer
    let lineWidth: CGFloat
    let layerInsetPerSide: CGFloat

    var body: some View {
        ZStack {
            ForEach(layer.angleModels) { model in
                OneIngestionView(
                    angleModel: model,
                    lineWidth: lineWidth,
                    insetPerSide: layerInsetPerSide
                )
            }
        }
    }
}

struct OneLayerView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        OneLayerView(
            layer: WatchFaceModel(ingestions: helper.experiences.first!.sortedIngestionsUnwrapped).layers.first!,
            lineWidth: 20,
            layerInsetPerSide: 10
        )
    }
}
