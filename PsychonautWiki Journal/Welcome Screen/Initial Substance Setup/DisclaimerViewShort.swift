import SwiftUI

struct DisclaimerViewShort: View {

    @AppStorage(PersistenceController.hasBeenSetupBeforeKey) var hasBeenSetupBefore: Bool = false
    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: []
    ) var storedFile: FetchedResults<SubstancesFile>

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        VStack(spacing: 20) {

            ScrollView {
                Image(systemName: "exclamationmark.triangle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80, alignment: .center)
                    .accessibilityHidden(true)
                    .foregroundColor(.red)
                Text("Disclaimer")
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .font(.largeTitle.bold())
                    .foregroundColor(.red)
                    .padding(.bottom)

                Text("""
                There is no guarantee that the substance \
                information is correct or complete. \
                Any reliance you place on the app is strictly at your own risk. \
                Consult a doctor before making medical decisions.
                """)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(.red)
                Spacer()
            }

            if let file = storedFile.first {
                NavigationLink(
                    destination: ChooseInitialInteractionsView(
                        file: file,
                        dismiss: dismiss
                    ),
                    label: {
                        Text("I understand.")
                            .primaryButtonText()
                    }
                )
            } else {
                Button("I understand.", action: dismiss)
                    .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding()
        .navigationBarHidden(true)
    }

    private func dismiss() {
        hasBeenSetupBefore = true
    }
}

struct ImportSubstancesScreen_Previews: PreviewProvider {

    static var previews: some View {
        DisclaimerViewShort()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(CalendarWrapper())
    }
}
