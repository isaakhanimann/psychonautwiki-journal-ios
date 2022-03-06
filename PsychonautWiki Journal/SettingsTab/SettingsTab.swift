import SwiftUI

struct SettingsTab: View {

    @StateObject private var viewModel = ViewModel()
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false

    var body: some View {
        NavigationView {
            List {
                eye
                Section(header: Text("Last Successfull Substance Fetch")) {
                    if viewModel.isFetching {
                        Text("Fetching Substances...")
                    } else {
                        Button(action: viewModel.fetchNewSubstances, label: {
                            Label(
                                viewModel.substancesFile?.creationDateUnwrapped.asDateAndTime ?? "No Substances",
                                systemImage: "arrow.clockwise"
                            )
                        })
                    }
                }
                .alert(isPresented: $viewModel.isShowingErrorAlert) {
                    Alert(
                        title: Text("Try Again Later"),
                        message: Text(viewModel.alertMessage),
                        dismissButton: .default(Text("Ok"))
                    )
                }

                if isEyeOpen {
                    Section(header: Text("Safety")) {
                        Link(
                            "Responsible Use",
                            destination: URL(string: "https://psychonautwiki.org/wiki/Responsible_drug_use")!
                        )
                    }

                    NavigationLink(
                        destination: FAQView(),
                        label: {
                            Label("Frequently Asked Questions", systemImage: "questionmark.square")
                        }
                    )
                }

                Section("Communication") {
                    Link(
                        "Send Me Feedback & Questions",
                        destination: URL(string: "https://t.me/isaakhanimann")!
                    )
                }
            }.navigationTitle("Settings")
        }
    }

    private var eye: some View {
        HStack {
            Spacer()
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80, alignment: .center)
                .onTapGesture(count: 3, perform: toggleEye)
            Spacer()
        }
        .listRowBackground(Color.clear)
    }

    private var imageName: String {
        isEyeOpen ? "Eye Open" : "Eye Closed"
    }

    private func toggleEye() {
        isEyeOpen.toggle()
        playHapticFeedback()
        changeAppIcon(toOpen: isEyeOpen)
        Connectivity.shared.sendEyeState(isEyeOpen: isEyeOpen)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTab()
            .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
            .environmentObject(CalendarWrapper())
            .accentColor(Color.blue)
    }
}
