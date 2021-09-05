import SwiftUI

struct SettingsTab: View {

    @Environment(\.managedObjectContext) var moc

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: []
    ) var storedFile: FetchedResults<SubstancesFile>

    @State private var isShowingErrorAlert = false
    @State private var alertMessage = ""
    @State private var isFetching = false

    var body: some View {
        NavigationView {
            List {

                Section(header: Text("Last Fetch")) {
                    if isFetching {
                        Text("Fetching...")
                    } else {
                        Button(action: fetchNewSubstances, label: {
                            Label(
                                storedFile.first!.creationDateUnwrapped.asDateAndTime,
                                systemImage: "arrow.clockwise"
                            )
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

                Section(header: Text("Choose Interactions")) {
                    NavigationLink(
                        destination: ChooseInteractionsView(file: storedFile.first!),
                        label: {
                            Label(
                                "Interactions",
                                systemImage: "burst.fill"
                            )
                        }
                    )
                }

                Section(header: Text("Choose Favorites")) {
                    NavigationLink(
                        destination: ChooseFavoritesView(file: storedFile.first!),
                        label: {
                            Label("Favorites", systemImage: "star.fill")
                        }
                    )
                }

            }
            .navigationTitle("Settings")
        }
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

struct SettingsTab_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTab()
    }
}
