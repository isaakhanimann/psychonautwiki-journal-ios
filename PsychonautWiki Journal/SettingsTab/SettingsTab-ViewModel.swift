import Foundation
import CoreData

extension SettingsTab {
    class ViewModel: ObservableObject {
        @Published var isFetching = false
        @Published var isResetting = false
        var toastViewModel: ToastViewModel?
    }
}
