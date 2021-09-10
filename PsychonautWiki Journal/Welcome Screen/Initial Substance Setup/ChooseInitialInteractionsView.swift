import SwiftUI

struct ChooseInitialInteractionsView: View {

    @ObservedObject var file: SubstancesFile
    let dismiss: () -> Void

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        VStack {
            Image(systemName: "burst.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80, alignment: .center)
                .accessibilityHidden(true)
                .foregroundColor(.accentColor)
            Text("Choose Interactions")
                .multilineTextAlignment(.center)
                .font(.largeTitle.bold())
            Text("Get notified of dangerous interactions with:")
                .font(.headline)
                .foregroundColor(.secondary)
            List {
                ForEach(file.generalInteractionsUnwrappedSorted) { interaction in
                    InteractionRowView(interaction: interaction)
                }
            }
            Button("Done", action: dismiss)
                .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal)
        .navigationBarHidden(true)
        .onDisappear {
            if moc.hasChanges {
                try? moc.save()
            }
        }
    }
}

struct ChooseInitialInteractionsView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        ChooseInitialInteractionsView(file: helper.substancesFile, dismiss: {})
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .accentColor(Color.blue)
    }
}
