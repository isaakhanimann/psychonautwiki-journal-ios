import SwiftUI

class AddIngestionSheetContext: ObservableObject {
    let experience: Experience?
    let showSuccessToast: () -> Void
    @Binding var isShowingAddIngestionSheet: Bool

    init(
        experience: Experience?,
        showSuccessToast: @escaping () -> Void,
        isShowingAddIngestionSheet: Binding<Bool>
    ) {
        self.experience = experience
        self.showSuccessToast = showSuccessToast
        self._isShowingAddIngestionSheet = isShowingAddIngestionSheet
    }
}
