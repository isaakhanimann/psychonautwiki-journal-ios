import Foundation

extension ContentView {
    class ViewModel: ObservableObject {
        @Published var isEyeOpen = false {
            didSet {
                UserDefaults.standard.set(isEyeOpen, forKey: PersistenceController.isEyeOpenKey)
            }
        }
        var toastViewModel: ToastViewModel?

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
                self.toastViewModel?.showErrorToast(message: "\(substanceName) Not Found")
            } else {
                self.toastViewModel?.showErrorToast(message: "No Substance Found")
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
