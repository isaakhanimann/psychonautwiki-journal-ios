import SwiftUI
import AlertToast

struct ContentView: View {

    @AppStorage(PersistenceController.needsToSeeWelcomeKey) var needsToSeeWelcome: Bool = true
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject private var toastViewModel: ToastViewModel
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false
    @AppStorage("hasBeenMigrated2") var hasBeenMigrated2: Bool = false

    var body: some View {
        AllTabs()
            .onOpenURL(perform: viewModel.receiveURL)
            .toast(isPresenting: $toastViewModel.isShowingErrorToast) {
                AlertToast(
                    displayMode: .alert,
                    type: .error(.red),
                    title: toastViewModel.errorToastMessage
                )
            }
            .toast(isPresenting: $toastViewModel.isShowingSuccessToast) {
                AlertToast(
                    displayMode: .alert,
                    type: .complete(Color.green),
                    title: toastViewModel.successToastMessage
                )
            }
            .fullScreenCover(isPresented: $needsToSeeWelcome) {
                WelcomeScreen(isShowingWelcome: $needsToSeeWelcome)
            }
            .task {
                viewModel.toastViewModel = toastViewModel
                if !hasBeenMigrated2 {
                    PersistenceController.shared.migrate()
                    hasBeenMigrated2 = true
                }
            }
    }
}
