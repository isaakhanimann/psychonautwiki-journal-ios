import SwiftUI

struct ChooseEnabledSubstancesView: View {

    @ObservedObject var file: SubstancesFile

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        List {
            ForEach(file.sortedCategoriesUnwrapped) { category in
                if !category.substancesUnwrapped.isEmpty {
                    Section(header: Text(category.nameUnwrapped)) {
                        ForEach(category.sortedSubstancesUnwrapped) { substance in
                            EnabledSubstanceRowView(substance: substance)
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Choose Substances")
        .onDisappear {
            if moc.hasChanges {
                try? moc.save()
            }
        }
    }
}

struct ChooseActiveSubstancesView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        ChooseEnabledSubstancesView(file: helper.substancesFile)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
