import SwiftUI
import AlertToast

struct ContentView: View {

    @AppStorage(PersistenceController.needsToSeeWelcomeKey) var needsToSeeWelcome: Bool = true
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject private var toastViewModel: ToastViewModel
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false
    @AppStorage("hasBeenMigrated2") var hasBeenMigrated2: Bool = false

    var body: some View {
        RootScreen()
            .onOpenURL(perform: { url in
                viewModel.receiveURL(url: url)
            })
            .toast(isPresenting: $toastViewModel.isShowingToast) {
                AlertToast(
                    displayMode: .alert,
                    type: toastViewModel.isSuccessToast ? .complete(.green): .error(.red),
                    title: toastViewModel.toastMessage
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
