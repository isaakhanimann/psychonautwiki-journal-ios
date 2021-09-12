import SwiftUI

struct ChooseEnabledSubstancesView: View {

    @ObservedObject var file: SubstancesFile

    @State private var areAllSubstancesEnabled: Bool = false

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var connectivity: Connectivity

    init(file: SubstancesFile) {
        self.file = file
        self._areAllSubstancesEnabled = State(wrappedValue: file.allSubstancesUnwrapped.allSatisfy {$0.isEnabled})
    }

    var body: some View {
        List {
            ForEach(file.sortedCategoriesUnwrapped) { category in
                if !category.substancesUnwrapped.isEmpty {
                    Section(header: Text(category.nameUnwrapped)) {
                        ForEach(category.sortedSubstancesUnwrapped) { substance in
                            EnabledSubstanceRowView(substance: substance, updateAllToggle: updateAllToggle)
                        }
                    }
                }
            }
        }
        .toolbar {
            let toggleBinding = Binding<Bool>(
                get: {self.areAllSubstancesEnabled},
                set: {
                    self.areAllSubstancesEnabled = $0
                    toggleAllSubstances(to: $0)
                }
            )
            ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                Toggle("Enable All", isOn: toggleBinding.animation())
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Choose Substances")
        .onDisappear {
            if moc.hasChanges {
                connectivity.sendEnabledSubstances(from: file)
                try? moc.save()
            }
        }
    }

    private func toggleAllSubstances(to isEnabled: Bool) {
        file.allSubstancesUnwrapped.forEach { substance in
            substance.isEnabled = isEnabled
        }
        if moc.hasChanges {
            try? moc.save()
        }
    }

    private func updateAllToggle() {
        self.areAllSubstancesEnabled = file.allSubstancesUnwrapped.allSatisfy {$0.isEnabled}
    }
}

struct ChooseActiveSubstancesView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        ChooseEnabledSubstancesView(file: helper.substancesFile)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
