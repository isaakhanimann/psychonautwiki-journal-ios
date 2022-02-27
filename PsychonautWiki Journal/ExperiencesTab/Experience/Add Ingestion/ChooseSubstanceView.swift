import SwiftUI

struct ChooseSubstanceView: View {

    @FetchRequest(
        entity: Substance.entity(),
        sortDescriptors: [ ]
    ) var substances: FetchedResults<Substance>

    let dismiss: () -> Void
    let experience: Experience

    @State private var isKeyboardShowing = false
    @State private var searchText = ""

    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(substances) { substance in
                    SubstanceRow(substance: substance, dismiss: dismiss, experience: experience)
                }

                if isEyeOpen {
                    Section {
                        EmptyView()
                    } footer: {
                        Text(Constants.substancesDisclaimerIOS)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Add Ingestion")
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                withAnimation {
                    isKeyboardShowing = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation {
                    isKeyboardShowing = false
                }
            }
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                    if isKeyboardShowing {
                        Button("Done", action: hideKeyboard)
                    } else {
                        Button("Cancel", action: dismiss)
                    }
                }
            }
        }
    }
}

struct ChooseSubstanceView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        ChooseSubstanceView(
            dismiss: {},
            experience: helper.experiences.first!
        )
            .environmentObject(helper.experiences.first!)
    }
}
