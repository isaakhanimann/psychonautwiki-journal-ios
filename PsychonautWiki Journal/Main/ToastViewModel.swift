import Foundation

class ToastViewModel: ObservableObject {
    @Published var isShowingSuccessToast = false
    @Published var isShowingErrorToast = false
    @Published var errorToastMessage = "Error"

    func showErrorToast(message: String) {
        errorToastMessage = message
        isShowingErrorToast = true
    }

    func showSuccessToast() {
        isShowingSuccessToast = true
    }
}
