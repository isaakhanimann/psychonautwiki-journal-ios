import SwiftUI

struct SettingsTab: View {

    @StateObject private var viewModel = ViewModel()
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false
    @EnvironmentObject private var toastViewModel: ToastViewModel
    @EnvironmentObject private var sheetViewModel: SheetViewModel

    var body: some View {
        NavigationView {
            List {
                eye
                substancesSection
                if isEyeOpen {
                    Section("Safety") {
                        Button {
                            sheetViewModel.sheetToShow = .article(
                                url: URL(string: "https://psychonautwiki.org/wiki/Responsible_drug_use")!
                            )
                        } label: {
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
                        Link(destination: URL(string: "https://github.com/isaakhanimann/PsychonautWiki-Journal")!) {
                            Label("Source Code", systemImage: "doc.text.magnifyingglass")
                        }
                    }
                }
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(getCurrentAppVersion())
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .task {
                viewModel.toastViewModel = toastViewModel
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
        Section("Substances") {
            HStack {
                Text("Last Refresh")
                Spacer()
                Text("-")
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

                    }
                } label: {
                    Label("Refresh Now", systemImage: "arrow.triangle.2.circlepath")
                }
                Button {
                    Task {

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
            .accentColor(Color.blue)
    }
}
