import SwiftUI

struct SettingsScreen: View {

    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false

    var body: some View {
        List {
            eye
            Section("Safety") {
                NavigationLink {
                    WebViewScreen(articleURL: URL(string: "https://psychonautwiki.org/wiki/Responsible_drug_use")!)
                } label: {
                    Label("Responsible Use", systemImage: "brain")
                }
            }
            Section("Communication") {
                ShareButton()
                RateInAppStoreButton()
                Link(destination: URL(string: "https://t.me/isaakhanimann")!) {
                    Label("Feature Requests / Bug Reports", systemImage: "exclamationmark.bubble")
                }
                Link(destination: URL(string: "https://t.me/isaakhanimann")!) {
                    Label("Ask a Question", systemImage: "ellipsis.bubble")
                }
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
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(getCurrentAppVersion())
                        .foregroundColor(.secondary)
                }
            }
        }.navigationTitle("Settings")
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
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
            .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
            .accentColor(Color.blue)
    }
}
