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
            guard let newModel = AngleModel(ingestion: ingestion) else {continue}
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
    let max1 = model1.max.asDoubleBetween0and360
    let min2 = model2.min.asDoubleBetween0and360
    let max2 = model2.max.asDoubleBetween0and360

    let isRange1OverZero = min1 > max1
    let isRange2OverZero = min2 > max2

    if !isRange1OverZero && !isRange2OverZero {
        let range1 = min1...max1
        let range2 = min2...max2
        return range1.overlaps(range2)
    } else if isRange1OverZero && !isRange2OverZero {
        return max2 > min1 || max1 > min2
    } else if isRange2OverZero && !isRange1OverZero {
        return max1 > min2 || max2 > min1
    } else {
        let range1 = min1...(max1 + 360)
        let range2 = min2...(max2 + 360)
        return range1.overlaps(range2)
    }
}
}
