import SwiftUI

struct SettingsView: View {

    let toggleSettingsVisibility: () -> Void

    @Environment(\.managedObjectContext) var moc

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: [ NSSortDescriptor(keyPath: \SubstancesFile.creationDate, ascending: false) ]
    ) var files: FetchedResults<SubstancesFile>
    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "isSelected == true")
    ) var selectedFile: FetchedResults<SubstancesFile>

    @State private var isShowingDeleteFileAlert = false
    @State private var offsets: IndexSet?
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            List {
                selectFileSection

                if !selectedFile.first!.generalInteractionsUnwrapped.isEmpty {
                    Section(header: Text("Notify me of unsafe and dangerous interactions with:")) {
                        ForEach(selectedFile.first!.generalInteractionsUnwrappedSorted) { interaction in
                            InteractionRowView(interaction: interaction)
                        }
                    }
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

    enum ActiveSheet: Identifiable {
        case shareSheet, addSheet

        // swiftlint:disable identifier_name
        var id: Int {
            hashValue
        }
    }

    private var selectFileSection: some View {
        Section {
            NavigationLink(destination: FilePickerView()) {
                HStack {
                    Text("Substances To Use")
                    Spacer()
                    Text(selectedFile.first!.filenameUnwrapped)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private func deleteFilesMaybe(at offsets: IndexSet) {
        self.offsets = offsets
        var ingestionDates = ""
        for offset in offsets {
            let file = files[offset]
            for category in file.categoriesUnwrapped {
                for substance in category.substancesUnwrapped {
                    for ingestion in substance.ingestionsUnwrappedSorted {
                        ingestionDates += "\(ingestion.timeUnwrapped.asDateString)"
                        ingestionDates += " (\(ingestion.timeUnwrapped.asTimeString), "
                    }
                }
            }
        }
        if ingestionDates.hasSuffix(", ") {
            ingestionDates.removeLast(2)
            self.alertMessage = "This will also delete following ingestions: " + ingestionDates
        } else {
            self.alertMessage = "There is no undo"
        }
        self.isShowingDeleteFileAlert.toggle()
    }

    private func deleteFiles() {
        for offset in self.offsets! {
            let file = files[offset]
            moc.delete(file)
        }
        if moc.hasChanges {
            try? moc.save()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(toggleSettingsVisibility: {})
    }
}
