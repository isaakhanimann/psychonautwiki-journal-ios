import SwiftUI
import AlertToast

struct ContentView: View {

    @AppStorage(PersistenceController.needsToSeeWelcomeKey) var needsToSeeWelcome: Bool = true
    @StateObject private var viewModel = ViewModel()
    var isShowingIngestion: Binding<Bool> {
        Binding {
            viewModel.foundSubstance != nil
        } set: {
            if !$0 {
                viewModel.foundSubstance = nil
            }
        }
    }

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
            .sheet(
                item: $viewModel.foundSubstance,
                onDismiss: {
                    viewModel.foundSubstance = nil
                }, content: { substance in
                    NavigationView {
                        if substance.hasAnyInteractions {
                            AcknowledgeInteractionsView(substance: substance)
                        } else {
                            ChooseRouteView(substance: substance)
                        }
                    }
                    .accentColor(Color.blue)
                    .environmentObject(
                        AddIngestionSheetContext(
                            experience: nil,
                            showSuccessToast: {
                                viewModel.isShowingAddSuccessToast.toggle()
                            },
                            isShowingAddIngestionSheet: isShowingIngestion
                        )
                    )
                }
            )
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
