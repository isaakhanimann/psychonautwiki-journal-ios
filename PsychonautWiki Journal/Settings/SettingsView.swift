import SwiftUI

struct SettingsView: View {

    let toggleSettingsVisibility: () -> Void

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var connectivity: Connectivity

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: []
    ) var storedFile: FetchedResults<SubstancesFile>

    @State private var isShowingErrorAlert = false
    @State private var alertMessage = ""
    @State private var isFetching = false

    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false

    var body: some View {
        NavigationView {
            List {

                Section(
                    header: Text("Last Successfull Substance Fetch"),
                    footer: Text("Source: PsychonautWiki")
                ) {
                    if isFetching {
                        Text("Fetching Substances...")
                    } else {
                        Button(action: fetchNewSubstances, label: {
                            Label(storedFile.first!.creationDateUnwrapped.asDateAndTime, systemImage: "arrow.clockwise")
                        })
                    }
                }
                .alert(isPresented: $isShowingErrorAlert) {
                    Alert(
                        title: Text("Fetch Failed"),
                        message: Text(alertMessage),
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

                    Section(header: Text("Dangerous Interaction Notifications")) {
                        NavigationLink(
                            destination: ChooseInteractionsView(file: storedFile.first!),
                            label: {
                                Label("Choose Interactions", systemImage: "burst.fill")
                            }
                        )
                    }

                    Section(header: Text("Favorites")) {
                        NavigationLink(
                            destination: ChooseFavoritesView(file: storedFile.first!),
                            label: {
                                Label("Choose Favorites", systemImage: "star.fill")
                            }
                        )
                    }
                }

                CalendarSection()

                Section(
                    footer: HStack {
                        Spacer()
                        (isEyeOpen ? Image("Eye Open") : Image("Eye Closed"))
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.secondary)
                            .frame(width: 30, height: 30, alignment: .center)
                            .onTapGesture(count: 3, perform: toggleEye)
                        Spacer()
                    }
                ) { }

            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(Text("Settings"))
            .navigationBarItems(
                trailing: Button("Done", action: toggleSettingsVisibility)
            )
            .onDisappear(perform: {
                if moc.hasChanges {
                    try? moc.save()
                }
            })
        }
        .currentDeviceNavigationViewStyle()
    }

    private func toggleEye() {
        isEyeOpen.toggle()
        PersistenceController.shared.toggleEye(to: isEyeOpen, modifyFile: storedFile.first!)
        connectivity.sendEyeState(isEyeOpen: isEyeOpen)
    }

    private func fetchNewSubstances() {
        isFetching = true
        PsychonautWikiAPIController.performRequest { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.alertMessage = "Request to PsychonautWiki API failed."
                    self.isShowingErrorAlert.toggle()
                    self.isFetching = false
                }
            case .success(let data):
                tryToDecodeData(data: data)
            }
        }
    }

    private func tryToDecodeData(data: Data) {
        do {
            try SubstanceDecoder.decodeAndSaveFile(
                from: data,
                creationDate: Date(),
                earlierFileToDelete: storedFile.first
            )
        } catch {
            DispatchQueue.main.async {
                self.alertMessage = "Not enough substances could be parsed."
                self.isShowingErrorAlert.toggle()
            }
        }
        DispatchQueue.main.async {
            self.isFetching = false
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(toggleSettingsVisibility: {})
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(Connectivity())
            .environmentObject(CalendarWrapper())
            .accentColor(Color.blue)
    }
}
