import Foundation

protocol SubstanceInteractable {
    var uncertainSubstancesUnwrapped: [Substance] { get }
    var unsafeSubstancesUnwrapped: [Substance] { get }
    var dangerousSubstancesUnwrapped: [Substance] { get }
    func addToUncertainSubstances(_ value: Substance)
    func addToUnsafeSubstances(_ value: Substance)
    func addToDangerousSubstances(_ value: Substance)
}
