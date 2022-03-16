import SwiftUI
import AlertToast

struct ContentView: View {

    @AppStorage(PersistenceController.hasSeenWelcomeKey) var hasSeenWelcome: Bool = false
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        if hasSeenWelcome {
            AllTabs()
                .onOpenURL(perform: viewModel.receiveURL)
                .toast(isPresenting: $viewModel.isShowingErrorToast) {
                    AlertToast(
                        displayMode: .alert,
                        type: .error(.red),
                        title: viewModel.toastMessage
                    )
                }
                .toast(isPresenting: $viewModel.isShowingAddSuccessToast) {
                    AlertToast(
                        displayMode: .alert,
                        type: .complete(Color.green),
                        title: "Ingestion Added"
                    )
                }
                .sheet(item: $viewModel.foundSubstance) { substance in
                    NavigationView {
                        if substance.hasAnyInteractions {
                            AcknowledgeInteractionsView(
                                substance: substance,
                                dismiss: viewModel.dismiss,
                                experience: nil
                            )
                        } else {
                            ChooseRouteView(
                                substance: substance,
                                dismiss: viewModel.dismiss,
                                experience: nil
                            )
                        }
                    }
                    .accentColor(Color.blue)
                }
        } else {
            WelcomeScreen()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
