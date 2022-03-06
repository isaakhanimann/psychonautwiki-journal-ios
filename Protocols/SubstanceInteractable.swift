import Foundation

protocol SubstanceInteractable {
    var uncertainSubstancesToShow: [Substance] { get }
    var unsafeSubstancesToShow: [Substance] { get }
    var dangerousSubstancesToShow: [Substance] { get }
}
