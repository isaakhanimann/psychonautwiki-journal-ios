import SwiftUI

struct SettingsScreen: View {
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        SettingsContent(
            isEyeOpen: $isEyeOpen,
            isImporting: $viewModel.isImporting,
            isExporting: $viewModel.isExporting,
            journalFile: viewModel.journalFile
        )
    }
}

struct SettingsContent: View {

    @Binding var isEyeOpen: Bool
    @Binding var isImporting: Bool
    @Binding var isExporting: Bool
    var journalFile: JournalFile

    var body: some View {
        List {
            eye
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

            Section("Data") {
                Button {
                    isExporting.toggle()
                } label: {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                }.fileExporter(
                    isPresented: $isExporting,
                    document: journalFile,
                    contentType: .json,
                    defaultFilename: "Journal"
                ) { result in
                    if case .success = result {
                        print("Export successful")
                    } else {
                        print("Export failed")
                    }
                }
                Button {
                    isImporting.toggle()
                } label: {
                    Label("Import Data", systemImage: "square.and.arrow.down")
                }.fileImporter(
                    isPresented: $isImporting,
                    allowedContentTypes: [.json]
                ) { result in
                    do {
                        let selectedFile: URL = try result.get()
                        guard let message = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
                        print("Import success")
                        print(message)
                    } catch {
                        print("Import failed")
                    }
                }
                Button {
                    // Todo:
                } label: {
                    Label("Delete Everything", systemImage: "trash").foregroundColor(.red)
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

struct SettingsContent_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsContent(
                isEyeOpen: .constant(true),
                isImporting: .constant(false),
                isExporting: .constant(false),
                journalFile: JournalFile()
            )
            .accentColor(Color.blue)
        }
    }
}
