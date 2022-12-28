import SwiftUI

struct SettingsScreen: View {
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        SettingsContent(
            isEyeOpen: $isEyeOpen,
            isImporting: $viewModel.isImporting,
            isExporting: $viewModel.isExporting,
            journalFile: viewModel.journalFile,
            exportData: {
                viewModel.exportData()
            },
            importData: { data in
                viewModel.importData(data: data)
            }
        )
    }
}

struct SettingsContent: View {

    @Binding var isEyeOpen: Bool
    @Binding var isImporting: Bool
    @Binding var isExporting: Bool
    var journalFile: JournalFile
    @EnvironmentObject private var toastViewModel: ToastViewModel
    let exportData: () -> Void
    let importData: (Data) -> Void

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

            Section(
                header: Text("Data"),
                footer: Text("You can export all your data into a file on your phone and import it again at a later time. This way you can migrate your data to Android or delete the app without losing your data.")
            ) {
                Button {
                    exportData()
                } label: {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                }.fileExporter(
                    isPresented: $isExporting,
                    document: journalFile,
                    contentType: .json,
                    defaultFilename: "Journal"
                ) { result in
                    if case .success = result {
                        toastViewModel.showSuccessToast(message: "Export Successful")
                    } else {
                        toastViewModel.showErrorToast(message: "Export Failed")
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
                        let data = try Data(contentsOf: selectedFile)
                        importData(data)
                    } catch {
                        toastViewModel.showErrorToast(message: "Import Failed")
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
                journalFile: JournalFile(),
                exportData: {},
                importData: {_ in }
            )
            .accentColor(Color.blue)
        }
    }
}
