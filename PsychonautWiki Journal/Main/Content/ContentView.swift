import SwiftUI
import AlertToast

struct ContentView: View {

    @AppStorage(PersistenceController.needsToSeeWelcomeKey) var needsToSeeWelcome: Bool = true
    @StateObject private var viewModel = ViewModel()

    var body: some View {
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
            .sheet(isPresented: $viewModel.isShowingAddIngestionSheet) {
                if let substanceUnwrap = viewModel.foundSubstance {
                    NavigationView {
                        if substanceUnwrap.hasAnyInteractions {
                            AcknowledgeInteractionsView(substance: substanceUnwrap)
                        } else {
                            ChooseRouteView(substance: substanceUnwrap)
                        }
                    }
                    .accentColor(Color.blue)
                    .environmentObject(
                        AddIngestionSheetContext(
                            experience: nil,
                            showSuccessToast: {
                                viewModel.isShowingAddSuccessToast.toggle()
                            },
                            isShowingAddIngestionSheet: $viewModel.isShowingAddIngestionSheet
                        )
                    )
                } else {
                    Text("An error occured")
                }

            }
            .fullScreenCover(isPresented: $needsToSeeWelcome) {
                WelcomeScreen(isShowingWelcome: $needsToSeeWelcome)
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
