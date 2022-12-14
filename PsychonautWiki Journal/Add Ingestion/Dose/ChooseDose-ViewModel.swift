import Foundation

extension ChooseDoseScreen {

    class ViewModel: ObservableObject {
        @Published var selectedUnits: String? = UnitPickerOptions.mg.rawValue
        @Published var selectedPureDose: Double?
        @Published var purity = 100.0
        @Published var isEstimate = false
        @Published var isShowingNext = false
        private var impureDose: Double? {
            guard let selectedPureDose = selectedPureDose else { return nil }
            return selectedPureDose/purity * 100
        }
        private var impureDoseRounded: Double? {
            guard let dose = impureDose else { return nil }
            return round(dose*100)/100
        }
        var impureDoseText: String {
            (impureDoseRounded?.formatted() ?? "..") + " " + (selectedUnits ?? "")
        }

        func initializeUnits(routeUnits: String?) {
            if let routeUnits = routeUnits {
                self.selectedUnits = routeUnits
            }
        }

    }
}
