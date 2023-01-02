import SwiftUI
import AlertToast

struct ContentView: View {

    @AppStorage(PersistenceController.needsToSeeWelcomeKey) var needsToSeeWelcome: Bool = true
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject private var toastViewModel: ToastViewModel
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false
    @AppStorage("hasBeenMigrated2") var hasBeenMigrated2: Bool = false

    var body: some View {
        ContentScreen(
            isShowingCurrentExperience: $viewModel.isShowingCurrentExperience,
            isShowingHome: $viewModel.isShowingHome,
            isShowingSearch: $viewModel.isShowingSearch,
            isShowingSafer: $viewModel.isShowingSafer,
            isShowingSettings: $viewModel.isShowingSettings
        )
        .onOpenURL { url in
            viewModel.receiveURL(url: url)
        }
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

struct ContentScreen: View {
    @Binding var isShowingCurrentExperience: Bool
    @Binding var isShowingHome: Bool
    @Binding var isShowingSearch: Bool
    @Binding var isShowingSafer: Bool
    @Binding var isShowingSettings: Bool

    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: JournalScreen(isShowingCurrentExperience: $isShowingCurrentExperience),
                    isActive: $isShowingHome
                ) {
                    Label("Journal", systemImage: "house")
                }
                NavigationLink(
                    destination: SearchScreen(),
                    isActive: $isShowingSearch
                ) {
                    Label("Substances", systemImage: "magnifyingglass")
                }
                NavigationLink(
                    destination: SaferScreen(),
                    isActive: $isShowingSafer
                ) {
                    Label("Safer Use", systemImage: "cross")
                }
                NavigationLink(
                    destination: SettingsScreen(),
                    isActive: $isShowingSettings
                ) {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }.navigationViewStyle(.stack)
    }
}


struct ContentScreen_Previews: PreviewProvider {
    static var previews: some View {
        ContentScreen(
            isShowingCurrentExperience: .constant(false),
            isShowingHome: .constant(false),
            isShowingSearch: .constant(false),
            isShowingSafer: .constant(false),
            isShowingSettings: .constant(false)
        )
    }
}
