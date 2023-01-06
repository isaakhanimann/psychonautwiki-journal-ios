import Foundation

extension ContentView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var isEyeOpen = false {
            didSet {
                UserDefaults.standard.set(isEyeOpen, forKey: PersistenceController.isEyeOpenKey2)
            }
        }
        @Published var isShowingHome = true
        @Published var isShowingSearch = false
        @Published var isShowingSafer = false
        @Published var isShowingSettings = false

        var toastViewModel: ToastViewModel?

        init() {
            self.isEyeOpen = UserDefaults.standard.bool(forKey: PersistenceController.isEyeOpenKey2)
        }

        func receiveURL(url: URL) {
            if url.absoluteString == OpenExperienceURL {
                isShowingHome = true
                isShowingSearch = false
                isShowingSafer = false
                isShowingSettings = false
            } else {
                if !isEyeOpen {
                    isEyeOpen = true
                    self.toastViewModel?.showSuccessToast(message: "Unlocked")
                } else {
                    self.toastViewModel?.showSuccessToast(message: "Already Unlocked")
                }
            }
        }
    }
}
