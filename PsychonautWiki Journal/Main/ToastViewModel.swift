import Foundation

class ToastViewModel: ObservableObject {
    @Published var successToastMessage = "Success"
    @Published var isShowingSuccessToast = false
    @Published var isShowingErrorToast = false
    @Published var errorToastMessage = "Error"

    func showErrorToast(message: String) {
        errorToastMessage = message
        isShowingErrorToast = true
    }

    func showSuccessToast(message: String = "Ingestion Added") {
        successToastMessage = message
        isShowingSuccessToast = true
    }
}
