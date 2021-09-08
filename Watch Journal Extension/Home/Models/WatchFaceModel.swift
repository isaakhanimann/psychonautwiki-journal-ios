import SwiftUI

struct WatchFaceModel {

    let layers: [Layer]

    struct Layer: Identifiable {
        // swiftlint:disable identifier_name
        var id: Int {
            index
        }
        let index: Int
        var angleModels: [AngleModel]
    }

    init(ingestions: [Ingestion]) {
        var setupLayers = [Layer]()
        for ingestion in ingestions {
            let newModel = AngleModel(ingestion: ingestion)
            WatchFaceModel.put(model: newModel, intoLayers: &setupLayers)
        }
        self.layers = setupLayers
    }

    private static func put(model: AngleModel, intoLayers: inout [Layer]) {
        for (index, layer) in intoLayers.enumerated() {
            if doesModelFitIntoLayer(model: model, layer: layer) {
                intoLayers[index].angleModels.append(model)
                return
            }
        }
        intoLayers.append(Layer(index: intoLayers.count, angleModels: [model]))
    }

    private static func doesModelFitIntoLayer(model: AngleModel, layer: Layer) -> Bool {
        for otherModels in layer.angleModels {
            if areModelsOverlapping(model1: model, model2: otherModels) {
                return false
            }
        }
        return true
    }

    private static func areModelsOverlapping(model1: AngleModel, model2: AngleModel) -> Bool {

        let min1 = model1.min.asDoubleBetween0and360
        var max1 = model1.max.asDoubleBetween0and360
        if min1 > max1 {
            max1 += 360
        }
        let min2 = model2.min.asDoubleBetween0and360
        var max2 = model2.max.asDoubleBetween0and360
        if min2 > max2 {
            max2 += 360
        }
        let range1 = min1...max1
        let range2 = min2...max2

        return range1.overlaps(range2)
    }

    func areRangesOverlapping(min1: Angle, max1: Angle, min2: Angle, max2: Angle) -> Bool {
        let min1 = min1.asDoubleBetween0and360
        var max1 = max1.asDoubleBetween0and360
        if min1 > max1 {
            max1 += 360
        }
        let min2 = min2.asDoubleBetween0and360
        var max2 = max2.asDoubleBetween0and360
        if min2 > max2 {
            max2 += 360
        }
        let range1 = min1...max1
        let range2 = min2...max2

        return range1.overlaps(range2)
    }
}
