import SwiftUI
import AlertToast

struct SettingsTab: View {

    @StateObject private var viewModel = ViewModel()
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false

    var body: some View {
        NavigationView {
            List {
                eye
                substancesSection
                if isEyeOpen {
                    Section(header: Text("Safety")) {
                        Link(destination: URL(string: "https://psychonautwiki.org/wiki/Responsible_drug_use")!) {
                            Label("Responsible Use", systemImage: "brain")
                        }
                    }
                }
                Section("Communication") {
                    ShareButton()
                    if isEyeOpen {
                        RateInAppStoreButton()
                    }
                    Link(destination: URL(string: "https://t.me/isaakhanimann")!) {
                        Label("Feature Requests / Bug Reports", systemImage: "exclamationmark.bubble")
                    }
                    Link(destination: URL(string: "https://t.me/isaakhanimann")!) {
                        Label("Ask a Question", systemImage: "ellipsis.bubble")
                    }
                    if isEyeOpen {
                        NavigationLink(
                            destination: FAQView(),
                            label: {
                                Label("Frequently Asked Questions", systemImage: "questionmark.square")
                            }
                        )
                        .foregroundColor(.accentColor)
                    }
                }
                Section {
                    Text("Version 1.0.6")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .toast(isPresenting: $viewModel.isShowingErrorAlert, duration: 3) {
                AlertToast(
                    displayMode: .alert,
                    type: .error(Color.red),
                    title: "Try Again Later"
                )
            }
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
        NotificationCenter.default.post(name: Notification.eyeName, object: nil)
        playHapticFeedback()
    }

    private var substancesSection: some View {
        Section(header: Text("Substances")) {
            HStack {
                Text("Last Refresh")
                Spacer()
                Text(viewModel.substancesFile?.creationDate?.asDateAndTime ?? "-")
                    .foregroundColor(.secondary)
            }
            if viewModel.isFetching {
                Text("Fetching Substances...")
                    .foregroundColor(.secondary)
            } else if viewModel.isResetting {
                Text("Resetting Substances...")
                    .foregroundColor(.secondary)
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
