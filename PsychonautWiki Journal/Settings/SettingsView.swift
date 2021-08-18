import SwiftUI
import SwiftyJSON

struct SettingsView: View {

    let toggleSettingsVisibility: () -> Void

    @Environment(\.managedObjectContext) var moc

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: []
    ) var storedFile: FetchedResults<SubstancesFile>

    @State private var isShowingErrorAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Substances and Interactions")) {

                    VStack(spacing: 10) {
                        Text("Last Successfull Fetch: \(storedFile.first!.creationDateUnwrapped.asDateAndTime)")
                            .fixedSize(horizontal: false, vertical: true)
                        Button(action: fetchNewSubstances, label: {
                            Label("Fetch Now", systemImage: "arrow.clockwise")
                        })
                    }
                    .alert(isPresented: $isShowingErrorAlert) {
                        Alert(
                            title: Text("Fetch Failed"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("Ok"))
                        )
                    }

                    NavigationLink(
                        destination: ChooseInteractionsView(file: storedFile.first!),
                        label: {
                            Label("Choose Interactions", systemImage: "burst.fill")
                        }
                    )

                    NavigationLink(
                        destination: ChooseFavoritesView(file: storedFile.first!),
                        label: {
                            Label("Choose Favorites", systemImage: "star.fill")
                        }
                    )
                }

                CalendarSection()

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

    private func fetchNewSubstances() {
        PsychonautWikiAPIController.performRequest { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.alertMessage = "Request to PsychonautWiki API failed."
                    self.isShowingErrorAlert.toggle()
                }
            case .success(let data):
                tryToDecodeData(data: data)
            }
        }
    }

    private func tryToDecodeData(data: Data) {
        do {
            let json = try JSON(data: data)
            let dataForFile = try json["data"].rawData()
            try SubstanceDecoder.decodeAndSaveFile(
                from: dataForFile,
                creationDate: Date(),
                earlierFileToDelete: storedFile.first
            )
        } catch {
            DispatchQueue.main.async {
                self.alertMessage = "Not enough substances could be parsed."
                self.isShowingErrorAlert.toggle()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(toggleSettingsVisibility: {})
    }
}
