import Foundation

extension ContentView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var isEyeOpen = false {
            didSet {
                UserDefaults.standard.set(isEyeOpen, forKey: PersistenceController.isEyeOpenKey)
            }
        }
        @Published var isShowingHome = true
        @Published var isShowingSearch = false
        @Published var isShowingSafer = false
        @Published var isShowingSettings = false
        @Published var isShowingCurrentExperience = true

        var toastViewModel: ToastViewModel?

        init() {
            self.isEyeOpen = UserDefaults.standard.bool(forKey: PersistenceController.isEyeOpenKey)
        }

        func receiveURL(url: URL) {
            if url.absoluteString == OpenExperienceURL {
                isShowingHome = true
                isShowingSearch = false
                isShowingSafer = false
                isShowingSettings = false
                isShowingCurrentExperience = true
            } else {
                if !isEyeOpen {
                    isEyeOpen = true
                }
                handleUniversalUrl(universalUrl: url)
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
