import SwiftUI

struct AddComponentView: View {

    let addComponent: (Component) -> Void
    @Binding var presetName: String
    @Binding var presetUnit: String?
    @StateObject private var viewModel = ViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Substance")) {
                    Picker("Substance", selection: $viewModel.selectedSubstance) {
                        ForEach(viewModel.sortedSubstances) { sub in
                            Text(sub.nameUnwrapped).tag(sub)
                        }
                    }
                }
                Section(header: Text("Administration Route")) {
                    Picker("Administration Route", selection: $viewModel.administrationRoute) {
                        ForEach(AdministrationRoute.allCases) { route in
                            Text(route.rawValue).tag(route)
                        }
                    }
                }
                Section(
                    header: Text("Dose in 1 \(presetUnit ?? "unit") of \(presetName.isEmpty ? "preset" : presetName)")
                ) {
                    DoseView(roaDose: viewModel.roaDose)
                    DosePicker(
                        roaDose: viewModel.roaDose,
                        doseMaybe: $viewModel.dosePerUnit,
                        selectedUnits: $viewModel.selectedUnit
                    )
                }
                .listRowSeparator(.hidden)
            }
            .navigationTitle("Add Component")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isEverythingNeededDefined {
                        Button("Done") {
                            let newComponent = viewModel.getComponent()
                            addComponent(newComponent)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
}

struct AddComponentView_Previews: PreviewProvider {
    static var previews: some View {
        AddComponentView(
            addComponent: {_ in},
            presetName: .constant(""),
            presetUnit: .constant("")
        )
    }
}
