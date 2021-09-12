import SwiftUI

struct ChooseInteractionsView: View {
    @ObservedObject var file: SubstancesFile

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var connectivity: Connectivity

    var body: some View {
        List {
            ForEach(file.generalInteractionsUnwrappedSorted) { interaction in
                InteractionRowView(interaction: interaction)
            }
        }
        .onDisappear {
            if moc.hasChanges {
                connectivity.sendInteractions(from: file)
                try? moc.save()
            }
        }
        .navigationTitle("Choose Interactions")
    }
}

struct ChooseInteractionsView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        ChooseInteractionsView(file: helper.substancesFile)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)

    }
}
