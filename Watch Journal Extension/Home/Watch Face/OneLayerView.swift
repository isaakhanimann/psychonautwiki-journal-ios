import SwiftUI

struct OneLayerView: View {

    let layer: WatchFaceModel.Layer
    let lineWidth: CGFloat

    var body: some View {
        ZStack {
            ForEach(layer.angleModels) { model in
                OneIngestionView(
                    angleModel: model,
                    lineWidth: lineWidth
                )
            }
        }
    }
}

struct OneLayerView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PreviewHelper()
        OneLayerView(
            layer: WatchFaceModel(ingestions: helper.experiences.first!.sortedIngestionsUnwrapped).layers.first!,
            lineWidth: 20
        )
        .padding(10)
    }
}
