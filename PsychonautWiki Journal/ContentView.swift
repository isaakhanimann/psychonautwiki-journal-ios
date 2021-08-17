import SwiftUI

struct ContentView: View {

    @AppStorage(PersistenceController.hasBeenSetupBeforeKey) var hasBeenSetupBefore: Bool = false
    @AppStorage(
        PersistenceController.isThereANewFileKey,
        store: UserDefaults(suiteName: PersistenceController.appGroupName)
    ) var isThereANewFile: Bool = false

    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var calendarWrapper: CalendarWrapper
    @EnvironmentObject var importSubstancesWrapper: SubstanceLinksWrapper
    @Environment(\.managedObjectContext) var moc

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "isNew == true")
    ) var newFile: FetchedResults<SubstancesFile>

    @State private var isThereAnErrorWithDownload: Bool = false
    @State private var errorMessage = ""
    @State private var isImporting = false
    @State private var areSettingsShowing = false

    var body: some View {
        let sheetBinding = Binding<ActiveSheet?>(
            get: {
                if !hasBeenSetupBefore {
                    return ActiveSheet.setup
                } else if isThereANewFile {
                    return ActiveSheet.importSuccess
                } else if isThereAnErrorWithDownload {
                    return ActiveSheet.importError
                } else if areSettingsShowing {
                    return ActiveSheet.settings
                } else {
                    return nil
                }
            },
            set: { _ in }
        )
        Group {
            if isImporting {
                ProgressView("Importing Substances...")
            } else {
                HomeView(toggleSettingsVisibility: toggleSettingsVisibility)
            }
        }
        .fullScreenCover(
            item: sheetBinding,
            content: { item in
                switch item {
                case .setup:
                    WelcomeScreen()
                        .environment(\.managedObjectContext, self.moc)
                        .environmentObject(calendarWrapper)
                        .environmentObject(importSubstancesWrapper)
                        .accentColor(Color.orange)
                case .importSuccess:
                    SelectNewFileView()
                        .environment(\.managedObjectContext, self.moc)
                        .accentColor(Color.orange)
                case .importError:
                    DownloadErrorView(
                        isThereAnErrorWithDownload: $isThereAnErrorWithDownload,
                        errorMessage: errorMessage
                    )
                    .environment(\.managedObjectContext, self.moc)
                    .accentColor(Color.orange)
                case .settings:
                    SettingsView(toggleSettingsVisibility: toggleSettingsVisibility)
                        .environment(\.managedObjectContext, self.moc)
                        .environmentObject(calendarWrapper)
                        .environmentObject(importSubstancesWrapper)
                        .accentColor(Color.orange)
                }
            })
        .onChange(of: scenePhase, perform: { newPhase in
            if newPhase == .active {
                calendarWrapper.checkIfSomethingChanged()
            }
        })
        .onAppear(perform: importSubstancesWrapper.downloadLinks)
        .onOpenURL(perform: handleUniversalUrl)
    }

    private func toggleSettingsVisibility() {
        areSettingsShowing.toggle()
    }

    private func handleUniversalUrl(universalUrl: URL) {
        self.isImporting = true
        if areSettingsShowing {
            areSettingsShowing = false
        }
        let (filename, downloadUrl) = getFilenameAndDownloadUrl(universalUrl: universalUrl)

        guard let filenameUnwrapped = filename else {
            errorMessage = "Failed to get filename"
            isThereAnErrorWithDownload = true
            isImporting = false
            return
        }
        guard let downloadUrlUnwrapped = downloadUrl else {
            errorMessage = "Failed to get download url"
            isThereAnErrorWithDownload = true
            isImporting = false
            return
        }

        downloadAndSaveFile(filename: filenameUnwrapped, downloadURL: downloadUrlUnwrapped)
    }

    enum ActiveSheet: Identifiable {
        case setup, importSuccess, importError, settings

        // swiftlint:disable identifier_name
        var id: Int {
            hashValue
        }
    }

    private func downloadAndSaveFile(filename: String, downloadURL: URL) {
        let request = URLRequest(url: downloadURL)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let errorUnwrapped = error {
                print(errorUnwrapped.localizedDescription)
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to open url"
                    self.isThereAnErrorWithDownload = true
                    self.isImporting = false
                }
                return
            }
            if let dataUnwrapped = data {
                handleDownloadedData(data: dataUnwrapped, filename: filename)
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load data"
                    self.isThereAnErrorWithDownload = true
                    self.isImporting = false
                }
            }
        }.resume()
    }

    private func handleDownloadedData(data: Data, filename: String) {
        do {
            try SubstanceDecoder.decodeAndSaveFile(
                from: data,
                with: filename
            )
            DispatchQueue.main.async {
                withAnimation {
                    self.isThereANewFile = true
                    self.isImporting = false
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to decode substances"
                self.isThereAnErrorWithDownload = true
                self.isImporting = false
            }
        }
    }

    private func getFilenameAndDownloadUrl(universalUrl: URL) -> (filename: String?, downloadUrl: URL?) {
        guard let componentsParsed = URLComponents(
            url: universalUrl,
            resolvingAgainstBaseURL: false
        ) else {
            return (nil, nil)
        }

        guard let queryItemsUnwrapped =  componentsParsed.queryItems else {
            return (nil, nil)
        }
        guard queryItemsUnwrapped.count == 2 else {
            return (nil, nil)
        }

        let filenameBack = queryItemsUnwrapped[0].value
        let downloadLinkBack = queryItemsUnwrapped[1].value

        guard let substancesDownloadUrl = URL(string: downloadLinkBack ?? "") else {
            return (filenameBack, nil)
        }

        return (filenameBack, substancesDownloadUrl)
    }
}
