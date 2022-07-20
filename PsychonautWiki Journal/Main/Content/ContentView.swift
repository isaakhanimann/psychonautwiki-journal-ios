import SwiftUI
import AlertToast

struct ContentView: View {

    @AppStorage(PersistenceController.needsToSeeWelcomeKey) var needsToSeeWelcome: Bool = true
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject private var sheetViewModel: SheetViewModel
    @EnvironmentObject private var toastViewModel: ToastViewModel
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false

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
            .sheet(item: $sheetViewModel.sheetToShow) { item in
                switch item {
                case .addIngestionFromContent(let foundSubstance):
                    NavigationView {
                        // TODO: — check if there are interactions and if not go straight to choose route
                        AcknowledgeInteractionsView(substance: foundSubstance)
                    }
                    .environmentObject(
                        AddIngestionSheetContext(experience: nil)
                    )
                case .addIngestionFromExperience(let experience):
                    ChooseSubstanceView()
                        .environmentObject(AddIngestionSheetContext(experience: experience))
                case .addIngestionFromSubstance(let substance):
                    NavigationView {
                        // TODO: — check if there are interactions and if not go straight to choose route
                        AcknowledgeInteractionsView(substance: substance)
                    }
                    .environmentObject(
                        AddIngestionSheetContext(experience: nil)
                    )
                case .addIngestionFromCustom(let custom):
                    NavigationView {
                        AddCustomIngestionView(customSubstance: custom)
                    }
                    .environmentObject(AddIngestionSheetContext(experience: nil))
                case .article(let url):
                    WebViewSheet(articleURL: url)
                case .addCustom:
                    AddCustomSubstanceView()
                }
            }
            .fullScreenCover(isPresented: $needsToSeeWelcome) {
                WelcomeScreen(isShowingWelcome: $needsToSeeWelcome)
            }
            .task {
                viewModel.sheetViewModel = sheetViewModel
                viewModel.toastViewModel = toastViewModel
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
