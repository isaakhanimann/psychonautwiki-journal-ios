import Foundation

extension ContentView {
    class ViewModel: ObservableObject {
        @Published var foundSubstance: Substance?
        @Published var isShowingAddIngestionSheet = false
        @Published var isShowingErrorToast = false
        @Published var isShowingAddSuccessToast = false
        @Published var toastMessage = ""
        @Published var isEyeOpen = false {
            didSet {
                UserDefaults.standard.set(isEyeOpen, forKey: PersistenceController.isEyeOpenKey)
            }
        }

        init() {
            self.isEyeOpen = UserDefaults.standard.bool(forKey: PersistenceController.isEyeOpenKey)
        }

        func receiveURL(url: URL) {
            if !isEyeOpen {
                self.isEyeOpen = true
            }
            DispatchQueue.main.async {
                self.handleUniversalUrl(universalUrl: url)
            }
        }

        private func handleUniversalUrl(universalUrl: URL) {
            if let substanceName = getSubstanceName(from: universalUrl) {
                if let foundSubstance = PersistenceController.shared.getSubstance(with: substanceName) {
                    self.foundSubstance = foundSubstance
                    self.isShowingAddIngestionSheet.toggle()
                } else {
                    self.isShowingErrorToast.toggle()
                    self.toastMessage = "\(substanceName) Not Found"
                }
            } else {
                self.isShowingErrorToast.toggle()
                self.toastMessage = "No Substance Found"
            }
        }

        private func getSubstanceName(from url: URL) -> String? {
            guard let componentsParsed = URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
            ) else {
                return nil
            }
            guard let queryItemsUnwrapped =  componentsParsed.queryItems else {
                return nil
            }
            return queryItemsUnwrapped.first?.value
        }
    }
}
