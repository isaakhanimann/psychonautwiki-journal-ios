import Foundation

protocol AroundShapeModel {
    var bottomLeft: DataPoint { get }
    var bottomRight: DataPoint { get }
    var curveToTopRight: Curve { get }
    var topLeft: DataPoint { get }
    var curveToBottomLeft: Curve { get }
}
