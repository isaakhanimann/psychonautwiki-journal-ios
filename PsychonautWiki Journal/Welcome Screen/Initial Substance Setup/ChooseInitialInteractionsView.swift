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
            Text("Notify me of dangerous and unsafe interactions with:")
                .foregroundColor(.secondary)
            List {
                ForEach(file.generalInteractionsUnwrappedSorted) { interaction in
                    InteractionRowView(interaction: interaction)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .cornerRadius(10)

            NavigationLink(
                destination: ChooseInitialFavoritesView(file: file, dismiss: dismiss),
                label: {
                    Text("Next")
                        .primaryButtonText()
                }
            )
            .isDetailLink(false)
        }
        .padding()
        .navigationBarHidden(true)
        .onDisappear {
            if moc.hasChanges {
                try? moc.save()
            }
        }
    }
}
