import SwiftUI

struct ImportSubstancesScrollView: View {

    @EnvironmentObject var substanceLinksWrapper: SubstanceLinksWrapper

    var body: some View {
        ScrollView {
            Image(systemName: "square.and.arrow.down")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80, alignment: .center)
                .accessibilityHidden(true)
                .foregroundColor(.accentColor)
            Text("Import Substances")
                .multilineTextAlignment(.center)
                .font(.largeTitle.bold())
            Text("Remember, there is no guarantee that the info on these substances is correct or complete.")
                .foregroundColor(.secondary)
                .padding()

            switch substanceLinksWrapper.downloadLinkState {
            case .downloading:
                ProgressView("Fetching Links...")
            case .error(let message):
                Text(message)
            case .success(let links):
                Text("Select substances to import:")
                    .font(.headline)
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(links, id: \.name) { link in
                        ImportFileRow(substancesLink: link)
                    }
                }
                .padding()
            }
        }
    }
}

struct ImportSubstancesGroup_Previews: PreviewProvider {
    static var previews: some View {
        ImportSubstancesScrollView()
    }
}
