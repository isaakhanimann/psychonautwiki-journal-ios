import SwiftUI

struct MaybeImportSubstancesScreen: View {

    @EnvironmentObject var substanceLinksWrapper: SubstanceLinksWrapper
    @Environment(\.presentationMode) var presentationMode

    @AppStorage(PersistenceController.hasAcceptedImportKey) var hasAcceptedImport: Bool = false

    var body: some View {
        Group {
            if hasAcceptedImport {
                ImportSubstancesScrollView()
                .onAppear(perform: substanceLinksWrapper.downloadLinks)
            } else {
                ImportDisclaimerView(
                    onDontImport: {
                        presentationMode.wrappedValue.dismiss()
                    },
                    understandPressed: understandPressed
                )
                .transition(.move(edge: .leading))
            }
        }
    }

    private func understandPressed() {
        withAnimation {
            hasAcceptedImport.toggle()
        }
    }
}

struct MaybeImportSubstancesScreen_Previews: PreviewProvider {
    static var previews: some View {
        MaybeImportSubstancesScreen()
    }
}
