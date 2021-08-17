import SwiftUI

struct EditCategoryView: View {

    @ObservedObject var category: Category

    @Environment(\.managedObjectContext) var moc

    @State private var name: String
    @State private var isShowingSheet = false
    @State private var isKeyboardShowing = false
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    @State private var offsets: IndexSet?

    init(category: Category) {
        self.category = category
        self._name = State(wrappedValue: category.nameUnwrapped)
    }

    var body: some View {
        Form {
            TextField("Enter Name", text: $name)
                .onChange(of: name) { _ in update() }

            Section(header: sectionHeader) {
                ForEach(category.sortedSubstancesUnwrapped) { substance in
                    NavigationLink(
                        destination: EditSubstanceView(substance: substance),
                        label: {
                            HStack {
                                Text(substance.nameUnwrapped)
                                Spacer()
                                if substance.isFavorite {
                                    Image(systemName: "star.fill")
                                        .font(.title2)
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                    )
                    .deleteDisabled(category.substancesUnwrapped.count == 1)
                }
                .onDelete(perform: deleteSubstancesMaybe)
            }
        }
        .sheet(isPresented: $isShowingSheet) {
            AddSubstanceView(category: category)
                .environment(\.managedObjectContext, self.moc)
                .accentColor(Color.orange)
        }
        .alert(isPresented: $isShowingAlert, content: {
            Alert(
                title: Text("Are you sure?"),
                message: Text(alertMessage),
                primaryButton: .destructive(Text("Delete")) {
                    deleteSubstances(at: offsets!)
                },
                secondaryButton: .cancel()
            )
        })
        .navigationTitle("Edit Category")
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

    private func update() {
        category.file!.objectWillChange.send()
        category.name = name
    }

    private func deleteSubstancesMaybe(at offsets: IndexSet) {
        self.offsets = offsets
        var ingestionDates = ""
        for offset in offsets {
            let substance = category.sortedSubstancesUnwrapped[offset]
            for ingestion in substance.ingestionsUnwrappedSorted {
                ingestionDates += "\(ingestion.timeUnwrapped.asDateString) (\(ingestion.timeUnwrapped.asTimeString), "
            }
        }
        if ingestionDates.hasSuffix(", ") {
            ingestionDates.removeLast(2)
            self.alertMessage = "This will also delete following ingestions: " + ingestionDates
        } else {
            self.alertMessage = "There is no undo"
        }
        self.isShowingAlert.toggle()
    }

    private func deleteSubstances(at offsets: IndexSet) {
        for offset in offsets {
            let substance = category.sortedSubstancesUnwrapped[offset]
            moc.delete(substance)
        }
        if moc.hasChanges {
            try? moc.save()
        }
    }

    var sectionHeader: some View {
        HStack {
            Text("Substances")
            Spacer()
            Button(action: {isShowingSheet.toggle()},
                   label: {
                    Label("Add Substance", systemImage: "plus")
                        .labelStyle(IconOnlyLabelStyle())
                   }
            )
        }
    }
}
