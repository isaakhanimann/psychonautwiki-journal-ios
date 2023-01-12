// Copyright (c) 2022. Isaak Hanimann.
// This file is part of PsychonautWiki Journal.
//
// PsychonautWiki Journal is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public Licence as published by
// the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// PsychonautWiki Journal is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PsychonautWiki Journal. If not, see https://www.gnu.org/licenses/gpl-3.0.en.html.

import SwiftUI
import AlertToast
import StoreKit

struct SettingsScreen: View {
    @AppStorage(PersistenceController.isEyeOpenKey2) var isEyeOpen: Bool = false
    @AppStorage("hasRatedBefore") var hasRatedBefore: Bool = false
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject var authenticator: Authenticator

    var body: some View {
        SettingsContent(
            isEyeOpen: $isEyeOpen,
            isFaceIDAvailable: authenticator.isFaceIDEnabled,
            hasToUnlockApp: $authenticator.hasToUnlockApp,
            hasRatedBefore: $hasRatedBefore,
            isExporting: $viewModel.isExporting,
            journalFile: viewModel.journalFile,
            exportData: {
                viewModel.exportData()
            },
            importData: { data in
                viewModel.importData(data: data)
            },
            deleteEverything: {
                viewModel.deleteEverything()
            },
            isShowingToast: $viewModel.isShowingToast,
            isSuccessToast: $viewModel.isShowingSuccessToast,
            toastMessage: $viewModel.toastMessage
        )
    }
}

struct SettingsContent: View {

    @Binding var isEyeOpen: Bool
    var isFaceIDAvailable: Bool
    @Binding var hasToUnlockApp: Bool
    @Binding var hasRatedBefore: Bool
    @State var isImporting = false
    @Binding var isExporting: Bool
    var journalFile: JournalFile
    @EnvironmentObject private var toastViewModel: ToastViewModel
    let exportData: () -> Void
    let importData: (Data) -> Void
    let deleteEverything: () -> Void
    @State private var isShowingDeleteAlert = false
    @Binding var isShowingToast: Bool
    @Binding var isSuccessToast: Bool
    @Binding var toastMessage: String

    var body: some View {
        List {
            eye
            Section("Privacy") {
                if isFaceIDAvailable {
                    Toggle("Require App Unlock", isOn: $hasToUnlockApp).tint(Color.accentColor)
                } else {
                    Text("Enable Face ID for Journal in settings to lock the app.")
                }
            }
            Section("Communication") {
                if #available(iOS 16.0, *) {
                    ShareLink("Share With a Friend", item: URL(string: "https://isaakhanimann.github.io")!)
                }
                if isEyeOpen && !hasRatedBefore {
                    Button {
                        if let windowScene = UIApplication.shared.currentWindow?.windowScene {
                            SKStoreReviewController.requestReview(in: windowScene)
                        }
                    } label: {
                        Label("Rate in App Store", systemImage: "star")
                    }
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
                    Link(destination: URL(string: "https://github.com/isaakhanimann/psychonautwiki-journal-ios")!) {
                        Label("Source Code", systemImage: "doc.text.magnifyingglass")
                    }
                }
            }

            Section(
                header: Text("Journal Data"),
                footer: Text("You can export all your data into a file on your phone and import it again at a later time. This way you can migrate your data to Android or delete the app without losing your data.")
            ) {
                Button {
                    exportData()
                } label: {
                    Label("Export Data", systemImage: "arrow.up.doc")
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
                    Label("Import Data", systemImage: "arrow.down.doc")
                }.fileImporter(
                    isPresented: $isImporting,
                    allowedContentTypes: [.json]
                ) { result in
                    do {
                        let selectedFile: URL = try result.get()
                        if selectedFile.startAccessingSecurityScopedResource() {
                            let data = try Data(contentsOf: selectedFile)
                            importData(data)
                        } else {
                            toastViewModel.showErrorToast(message: "Permission Denied")
                        }
                        selectedFile.stopAccessingSecurityScopedResource()
                    } catch {
                        toastViewModel.showErrorToast(message: "Import Failed")
                        print("Error getting data: \(error.localizedDescription)")
                    }
                }
                Button {
                    isShowingDeleteAlert.toggle()
                } label: {
                    Label("Delete Everything", systemImage: "trash").foregroundColor(.red)
                }
                .alert(isPresented: $isShowingDeleteAlert) {
                    Alert(
                        title: Text("Delete Everything?"),
                        message: Text("This will delete all your experiences, ingestions and custom substances."),
                        primaryButton: .destructive(Text("Delete"), action: deleteEverything),
                        secondaryButton: .cancel()
                    )
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
        .toast(isPresenting: $isShowingToast) {
            AlertToast(
                displayMode: .alert,
                type: isSuccessToast ? .complete(.green) : .error(.red),
                title: toastMessage
            )
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

    
}

struct SettingsContent_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsContent(
                isEyeOpen: .constant(true),
                isFaceIDAvailable: true,
                hasToUnlockApp: .constant(false),
                hasRatedBefore: .constant(false),
                isImporting: false,
                isExporting: .constant(false),
                journalFile: JournalFile(),
                exportData: {},
                importData: {_ in },
                deleteEverything: {},
                isShowingToast: .constant(false),
                isSuccessToast: .constant(false),
                toastMessage: .constant("")
            )
            .accentColor(Color.blue)
        }
    }
}
