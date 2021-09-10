import SwiftUI

struct ChooseInteractionsView: View {
    @ObservedObject var file: SubstancesFile

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        VStack(alignment: .leading) {
            Text("Get notified of dangerous interactions with:")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            List {
                ForEach(file.generalInteractionsUnwrappedSorted) { interaction in
                    InteractionRowView(interaction: interaction)
                }
            }
        }
        .onDisappear {
            if moc.hasChanges {
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
