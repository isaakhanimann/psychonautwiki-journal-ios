import SwiftUI

struct ChooseInitialFavoritesView: View {

    @ObservedObject var file: SubstancesFile
    let dismiss: () -> Void

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        VStack {
            Image(systemName: "star.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80, alignment: .center)
                .accessibilityHidden(true)
                .foregroundColor(.accentColor)
            Text("Choose Favorites")
                .multilineTextAlignment(.center)
                .font(.largeTitle.bold())
            List {
                ForEach(file.sortedCategoriesUnwrapped) { category in
                    if !category.substancesUnwrapped.isEmpty {
                        Section(header: Text(category.nameUnwrapped)) {
                            ForEach(category.sortedSubstancesUnwrapped) { substance in
                                FavoritesRowView(substance: substance)
                            }
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .cornerRadius(10)

            Button("Done", action: dismiss)
                .buttonStyle(PrimaryButtonStyle())
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
