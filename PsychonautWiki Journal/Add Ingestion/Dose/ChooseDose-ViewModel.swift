import Foundation

extension ChooseDoseView {

    class ViewModel: ObservableObject {
        @Published var selectedUnits: String?
        @Published var selectedPureDose: Double?
        @Published var purity = 100.0
        @Published var isShowingUnknownDoseAlert = false
        @Published var isShowingNext = false
        private var impureDose: Double? {
            guard let selectedPureDose = selectedPureDose else { return nil }
            return selectedPureDose/purity * 100
        }
        var impureDoseRounded: Double? {
            guard let dose = impureDose else { return nil }
            return round(dose*100)/100
        }

        func initializeUnits(routeUnits: String?) {
            self.selectedUnits = routeUnits
        }

    }
}
