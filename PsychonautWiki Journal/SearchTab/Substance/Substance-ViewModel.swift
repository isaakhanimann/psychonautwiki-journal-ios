import Foundation

extension SubstanceView {
    class ViewModel: ObservableObject {
        let substance: Substance

        init(substance: Substance) {
            self.substance = substance
        }
    }
}
