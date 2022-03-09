import Foundation
import UIKit

extension ContentView {
    class ViewModel: ObservableObject {
        @Published var foundSubstance: Substance?
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

        func dismiss(result: AddResult) {
            foundSubstance = nil
            if result == .ingestionWasAdded {
                isShowingAddSuccessToast.toggle()
            }
        }

        func receiveURL(url: URL) {
            popToRoot()
            if !isEyeOpen {
                openEye()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.handleUniversalUrl(universalUrl: url)
            }
        }

        private func popToRoot() {
            let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
            keyWindow?.rootViewController?.dismiss(animated: true)
        }

        private func openEye() {
            self.isEyeOpen = true
            Connectivity.shared.sendEyeState(isEyeOpen: true)
        }

        private func handleUniversalUrl(universalUrl: URL) {
            if let substanceName = getSubstanceName(from: universalUrl) {
                if let foundSubstance = PersistenceController.shared.getSubstance(with: substanceName) {
                    self.foundSubstance = foundSubstance
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
