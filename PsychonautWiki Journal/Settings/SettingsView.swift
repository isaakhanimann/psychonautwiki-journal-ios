import SwiftUI

struct SettingsView: View {

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var connectivity: Connectivity
    @Environment(\.presentationMode) var presentationMode

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: [ NSSortDescriptor(keyPath: \SubstancesFile.creationDate, ascending: false) ]
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

                CalendarSection()

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

                Link(
                    "Send Me Feedback & Questions",
                    destination: URL(string: "https://t.me/isaakhanimann")!
                )
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(Text("Settings"))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    (isEyeOpen ? Image("Eye Open") : Image("Eye Closed"))
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.secondary)
                        .frame(width: 30, height: 30, alignment: .center)
                        .onTapGesture(count: 3, perform: toggleEye)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
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
        playHapticFeedback()
        connectivity.sendEyeState(isEyeOpen: isEyeOpen)
    }

    private func playHapticFeedback() {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
    }

    private func fetchNewSubstances() {
        isFetching = true
        performPsychonautWikiAPIRequest { result in
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
            try PersistenceController.shared.decodeAndSaveFile(from: data)
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
        SettingsView()
            .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
            .environmentObject(Connectivity())
            .environmentObject(CalendarWrapper())
            .accentColor(Color.blue)
    }
}
