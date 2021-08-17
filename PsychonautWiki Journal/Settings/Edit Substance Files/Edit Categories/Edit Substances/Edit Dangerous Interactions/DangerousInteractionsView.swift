import SwiftUI

struct DangerousInteractionsView: View {

    @ObservedObject var substance: Substance

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        List {
            if !substance.category!.file!.generalInteractionsUnwrapped.isEmpty {
                Section(header: generalHeader) {
                    ForEach(substance.dangerousGeneralInteractionsUnwrapped) { generalInteraction in
                        Text(generalInteraction.nameUnwrapped)
                    }
                    .onDelete(perform: deleteGeneralInteraction)
                }
            }
            if !substance.category!.file!.categoriesUnwrapped.isEmpty {
                Section(header: categoryHeader) {
                    ForEach(substance.dangerousCategoryInteractionsUnwrapped) { categoryInteraction in
                        Text(categoryInteraction.nameUnwrapped)
                    }
                    .onDelete(perform: deleteCategoryInteraction)
                }
            }
            if !substance.category!.file!.allSubstancesUnwrapped.isEmpty {
                Section(header: substanceHeader) {
                    ForEach(substance.dangerousSubstanceInteractionsUnwrapped) { substanceInteraction in
                        Text(substanceInteraction.nameUnwrapped)
                    }
                    .onDelete(perform: deleteSubstanceInteraction)
                }
            }
        }
    }

    private func deleteGeneralInteraction(at offsets: IndexSet) {
        for offset in offsets {
            let interaction = substance.dangerousGeneralInteractionsUnwrapped[offset]
            moc.delete(interaction)
        }
        if moc.hasChanges {
            try? moc.save()
        }
    }

    private func deleteCategoryInteraction(at offsets: IndexSet) {
        for offset in offsets {
            let interaction = substance.dangerousCategoryInteractionsUnwrapped[offset]
            moc.delete(interaction)
        }
        if moc.hasChanges {
            try? moc.save()
        }
    }

    private func deleteSubstanceInteraction(at offsets: IndexSet) {
        for offset in offsets {
            let interaction = substance.dangerousSubstanceInteractionsUnwrapped[offset]
            moc.delete(interaction)
        }
        if moc.hasChanges {
            try? moc.save()
        }
    }

    private var generalHeader: some View {
        HStack {
            Text("General Interactions")
            Spacer()
            NavigationLink(
                "Edit",
                destination: EditDangerousGeneralInteractionsView(substance: substance)
            )
        }
    }

    private var categoryHeader: some View {
        HStack {
            Text("Category Interactions")
            Spacer()
            NavigationLink(
                "Edit",
                destination: EditDangerousCategoryInteractionsView(substance: substance)
            )
        }
    }

    private var substanceHeader: some View {
        HStack {
            Text("Substance Interactions")
            Spacer()
            NavigationLink(
                "Edit",
                destination: EditDangerousSubstanceInteractionsView(substance: substance)
            )
        }
    }
}
