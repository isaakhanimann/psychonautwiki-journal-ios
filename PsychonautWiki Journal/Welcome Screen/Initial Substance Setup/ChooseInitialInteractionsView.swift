import SwiftUI

struct ChooseInitialInteractionsView: View {

    @ObservedObject var file: SubstancesFile
    let dismiss: () -> Void

    @Environment(\.managedObjectContext) var moc

    @State private var isLoading = false

    var body: some View {
        if isLoading {
            ProgressView()
        } else {
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
                    .padding(.horizontal)
                Text("Get notified of dangerous interactions with:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                List {
                    ForEach(file.generalInteractionsUnwrappedSorted) { interaction in
                        InteractionRowView(interaction: interaction)
                    }
                }
                Button("Done", action: {
                    isLoading = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        dismiss()
                    }
                })
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)

            }
            .padding(.vertical)
            .navigationBarHidden(true)
            .onDisappear {
                if moc.hasChanges {
                    try? moc.save()
                }
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
