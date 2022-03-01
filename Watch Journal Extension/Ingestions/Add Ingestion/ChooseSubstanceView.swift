import SwiftUI

struct ChooseSubstanceView: View {

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: [ NSSortDescriptor(keyPath: \SubstancesFile.creationDate, ascending: false) ]
    ) var storedFile: FetchedResults<SubstancesFile>

    let dismiss: () -> Void
    let experience: Experience

    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(storedFile.first?.psychoactiveClassesSorted ?? []) { pClass in
                    Section(header: Text(pClass.nameUnwrapped)) {
                        ForEach(pClass.sortedSubstancesUnwrapped) { substance in
                            SubstanceRow(
                                substance: substance,
                                dismiss: dismiss,
                                experience: experience
                            )
                        }
                    }
                }
                if isEyeOpen {
                    Section {
                        EmptyView()
                    } footer: {
                        Text(Constants.substancesDisclaimerWatch)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
                    Button("Cancel", action: dismiss)
                }
            }
        }
    }
}

struct ChooseSubstanceView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PreviewHelper.shared
        ChooseSubstanceView(
            dismiss: {},
            experience: helper.experiences.first!
        )
    }
}
