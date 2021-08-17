import SwiftUI

struct UnsafeInteractionsView: View {

    @ObservedObject var substance: Substance

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        List {
            if !substance.category!.file!.generalInteractionsUnwrapped.isEmpty {
                Section(header: generalHeader) {
                    ForEach(substance.unsafeGeneralInteractionsUnwrapped) { generalInteraction in
                        Text(generalInteraction.nameUnwrapped)
                    }
                    .onDelete(perform: deleteGeneralInteraction)
                }
            }
            if !substance.category!.file!.categoriesUnwrapped.isEmpty {
                Section(header: categoryHeader) {
                    ForEach(substance.unsafeCategoryInteractionsUnwrapped) { categoryInteraction in
                        Text(categoryInteraction.nameUnwrapped)
                    }
                    .onDelete(perform: deleteCategoryInteraction)
                }
            }
            if !substance.category!.file!.allSubstancesUnwrapped.isEmpty {
                Section(header: substanceHeader) {
                    ForEach(substance.unsafeSubstanceInteractionsUnwrapped) { substanceInteraction in
                        Text(substanceInteraction.nameUnwrapped)
                    }
                    .onDelete(perform: deleteSubstanceInteraction)
                }
            }
        }
    }

    private func deleteGeneralInteraction(at offsets: IndexSet) {
        for offset in offsets {
            let interaction = substance.unsafeGeneralInteractionsUnwrapped[offset]
            moc.delete(interaction)
        }
        if moc.hasChanges {
            try? moc.save()
        }
    }

    private func deleteCategoryInteraction(at offsets: IndexSet) {
        for offset in offsets {
            let interaction = substance.unsafeCategoryInteractionsUnwrapped[offset]
            moc.delete(interaction)
        }
        if moc.hasChanges {
            try? moc.save()
        }
    }

    private func deleteSubstanceInteraction(at offsets: IndexSet) {
        for offset in offsets {
            let interaction = substance.unsafeSubstanceInteractionsUnwrapped[offset]
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
                destination: EditUnsafeGeneralInteractionsView(substance: substance)
            )
        }
    }

    private var categoryHeader: some View {
        HStack {
            Text("Category Interactions")
            Spacer()
            NavigationLink(
                "Edit",
                destination: EditUnsafeCategoryInteractionsView(substance: substance)
            )
        }
    }

    private var substanceHeader: some View {
        HStack {
            Text("Substance Interactions")
            Spacer()
            NavigationLink(
                "Edit",
                destination: EditUnsafeSubstanceInteractionsView(substance: substance)
            )
        }
    }
}
