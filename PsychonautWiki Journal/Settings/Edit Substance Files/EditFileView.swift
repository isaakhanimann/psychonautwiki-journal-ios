import SwiftUI

struct EditFileView: View {

    @ObservedObject var file: SubstancesFile

    @Environment(\.managedObjectContext) var moc

    @State private var filename: String
    @State private var isKeyboardShowing = false
    @State private var activeSheet: ActiveSheet?
    @State private var isShowingCategoryAlert = false
    @State private var isShowingInteractionAlert = false
    @State private var alertMessage = ""
    @State private var offsets: IndexSet?

    init(file: SubstancesFile) {
        self.file = file
        self._filename = State(wrappedValue: file.filenameUnwrapped)
    }

    var body: some View {
        Form {
            TextField("Enter Name", text: $filename)
                .onChange(of: filename) { _ in update() }

            Section(header: categoriesSectionHeader) {
                ForEach(file.categoriesUnwrappedSorted) { category in
                    NavigationLink(
                        category.nameUnwrapped,
                        destination: EditCategoryView(category: category)
                    )
                    .deleteDisabled(file.categoriesUnwrapped.count == 1)
                }
                .onDelete(perform: deleteCategoriesMaybe)
            }
            .alert(isPresented: $isShowingCategoryAlert, content: {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text(alertMessage),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteCategories(at: offsets!)
                    },
                    secondaryButton: .cancel()
                )
            })
            Section(header: generalInteractionsSectionHeader) {
                ForEach(file.generalInteractionsUnwrappedSorted) { interaction in
                    NavigationLink(
                        interaction.nameUnwrapped,
                        destination: EditFileGeneralInteractionView(generalInteraction: interaction)
                    )
                }
                .onDelete(perform: deleteInteractionsMaybe)
            }
            .alert(isPresented: $isShowingInteractionAlert, content: {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text(alertMessage),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteInteractions(at: offsets!)
                    },
                    secondaryButton: .cancel()
                )
            })
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .addCategorySheet:
                AddCategoryView(file: file)
                    .environment(\.managedObjectContext, self.moc)
                    .accentColor(Color.orange)
            case .addGeneralInteractionSheet:
                AddFileGeneralInteractionView(file: file)
                    .environment(\.managedObjectContext, self.moc)
                    .accentColor(Color.orange)
            }
        }
        .navigationTitle("Edit Definitions")
        .onDisappear(perform: {
            if moc.hasChanges {
                try? moc.save()
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation {
                isKeyboardShowing = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation {
                isKeyboardShowing = false
            }
        }
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                if isKeyboardShowing {
                    Button {
                        hideKeyboard()
                        if moc.hasChanges {
                            try? moc.save()
                        }
                    } label: {
                        Text("Done")
                            .font(.callout)
                    }
                }
            }
        }
    }

    enum ActiveSheet: Identifiable {
        case addCategorySheet, addGeneralInteractionSheet

        // swiftlint:disable identifier_name
        var id: Int {
            hashValue
        }
    }

    func update() {
        file.objectWillChange.send()
        file.filename = filename
    }

    private func deleteCategoriesMaybe(at offsets: IndexSet) {
        self.offsets = offsets
        var ingestionDates = ""
        for offset in offsets {
            let category = file.categoriesUnwrappedSorted[offset]
            for substance in category.substancesUnwrapped {
                for ingestion in substance.ingestionsUnwrappedSorted {
                    ingestionDates += "\(ingestion.timeUnwrapped.asDateString)"
                    ingestionDates += " (\(ingestion.timeUnwrapped.asTimeString), "
                }
            }
        }
        if ingestionDates.hasSuffix(", ") {
            ingestionDates.removeLast(2)
            self.alertMessage = "This will also delete following ingestions: " + ingestionDates
        } else {
            self.alertMessage = "There is no undo"
        }
        self.isShowingCategoryAlert.toggle()
    }

    private func deleteCategories(at offsets: IndexSet) {
        for offset in offsets {
            let category = file.categoriesUnwrappedSorted[offset]
            moc.delete(category)
        }
        if moc.hasChanges {
            do {
                try moc.save()
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }

    private func deleteInteractionsMaybe(at offsets: IndexSet) {
        self.offsets = offsets
        var substanceNames = ""
        for offset in offsets {
            let interaction = file.generalInteractionsUnwrappedSorted[offset]
            let substances = interaction.dangerousSubstanceInteractionsUnwrapped
                + interaction.unsafeSubstanceInteractionsUnwrapped
            let substancesUnique = substances.uniqued()
            for substance in substancesUnique {
                substanceNames += "\(substance.nameUnwrapped), "
            }
        }
        if substanceNames.hasSuffix(", ") {
            substanceNames.removeLast(2)
            self.alertMessage = "This interaction is used for following substances: " + substanceNames
        } else {
            self.alertMessage = "There is no undo"
        }
        self.isShowingInteractionAlert.toggle()
    }

    private func deleteInteractions(at offsets: IndexSet) {
        for offset in offsets {
            let interaction = file.generalInteractionsUnwrappedSorted[offset]
            moc.delete(interaction)
        }
        if moc.hasChanges {
            do {
                try moc.save()
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }

    var categoriesSectionHeader: some View {
        HStack {
            Text("Categories")
            Spacer()
            Button(
                action: {
                    self.activeSheet = .addCategorySheet
                },
                label: {
                    Label("Add Category", systemImage: "plus")
                        .labelStyle(IconOnlyLabelStyle())
                }
            )
        }
    }

    var generalInteractionsSectionHeader: some View {
        HStack {
            Text("General Interactions")
            Spacer()
            Button(
                action: {
                    self.activeSheet = .addGeneralInteractionSheet
                },
                label: {
                    Label("Add General Interaction", systemImage: "plus")
                        .labelStyle(IconOnlyLabelStyle())
                }
            )
        }
    }
}
