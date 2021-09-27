import SwiftUI

struct ChooseInteractionsView: View {
    @ObservedObject var file: SubstancesFile

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var connectivity: Connectivity

    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false

    var body: some View {
        VStack {
            #if os(iOS)
            Text("Get notified of dangerous interactions with:")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            #endif
            List {
                ForEach(file.getAllOkInteractionsSorted(showAllInteractions: isEyeOpen)) { interaction in
                    InteractionRowView(interaction: interaction)
                }
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
