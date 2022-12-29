import Foundation

@MainActor
class ToastViewModel: ObservableObject {
    @Published var toastMessage = ""
    @Published var isShowingToast = false
    @Published var isSuccessToast = false

    func showErrorToast(message: String = "Error") {
        toastMessage = message
        isShowingToast = true
        isSuccessToast = false
    }

    func showSuccessToast(message: String = "Ingestion Added") {
        toastMessage = message
        isShowingToast = true
        isSuccessToast = true
    }
}
