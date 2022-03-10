import SwiftUI

struct SettingsTab: View {

    @StateObject private var viewModel = ViewModel()
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Substances")) {
                    HStack {
                        Text("Last Update")
                        Spacer()
                        Text(viewModel.substancesFile?.creationDateUnwrapped.asDateAndTime ?? "-")
                            .foregroundColor(.secondary)
                    }
                    if viewModel.isFetching {
                        HStack(spacing: 10) {
                            ProgressView()
                            Text("Fetching Substances")
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Button {
                            Task {
                                await viewModel.fetchNewSubstances()
                            }
                        } label: {
                            Label("Refresh Now", systemImage: "arrow.triangle.2.circlepath")
                        }
                        Button {
                            Task {
                                await viewModel.resetSubstances()
                            }
                        } label: {
                            Label("Reset Substances", systemImage: "arrow.uturn.left.circle")
                        }
                    }
                }
                .alert(isPresented: $viewModel.isShowingErrorAlert) {
                    Alert(
                        title: Text("Try Again Later"),
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
