import SwiftUI

struct DisclaimerViewShort: View {

    @AppStorage(PersistenceController.hasBeenSetupBeforeKey) var hasBeenSetupBefore: Bool = false
    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: [ NSSortDescriptor(keyPath: \SubstancesFile.creationDate, ascending: false) ]
    ) var storedFile: FetchedResults<SubstancesFile>

    @Environment(\.managedObjectContext) var moc

    @State private var isLoading = false

    var body: some View {
        if isLoading {
            ProgressView()
        } else {
            VStack(spacing: 20) {
                ScrollView {
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80, alignment: .center)
                        .accessibilityHidden(true)
                        .foregroundColor(.red)
                    Text("Caution")
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .font(.largeTitle.bold())
                        .foregroundColor(.red)
                        .padding(.bottom)

                    // swiftlint:disable line_length
                    Text("Any reliance you place on PsychonautWiki Journal is strictly at your own risk. Consult a doctor before making medical decisions.")
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.red)
                    Spacer()
                }

                Button("I understand.", action: loadAndDismiss)
                    .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
            .navigationBarHidden(true)
        }
    }

    private func loadAndDismiss() {
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            hasBeenSetupBefore = true
        }
    }
}

struct ImportSubstancesScreen_Previews: PreviewProvider {

    static var previews: some View {
        DisclaimerViewShort()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(CalendarWrapper())
    }
}
