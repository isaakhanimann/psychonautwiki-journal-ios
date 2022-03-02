import SwiftUI

struct SettingsTab: View {

    @StateObject private var viewModel = ViewModel()
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false

    var body: some View {
        NavigationView {
            List {
                Section(
                    header: Text("Last Fetch"),
                    footer: Text("Source: PsychonautWiki").font(.system(size: 11))
                ) {
                    if viewModel.isFetching {
                        Text("Fetching...")
                    } else {
                        Button(action: viewModel.fetchNewSubstances, label: {
                            Label(
                                viewModel.substancesFile?.creationDate?.asDateAndTime ?? "No Substances",
                                systemImage: "arrow.clockwise"
                            )
                        })
                    }
                }
                .alert(isPresented: $viewModel.isShowingErrorAlert) {
                    Alert(
                        title: Text("Fetch Failed"),
                        message: Text(viewModel.alertMessage),
                        dismissButton: .default(Text("Ok"))
                    )
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsTab_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTab()
            .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
    }
}
