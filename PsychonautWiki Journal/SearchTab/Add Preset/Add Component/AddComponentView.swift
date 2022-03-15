import SwiftUI

struct AddComponentView: View {

    let addComponent: (Component) -> Void
    @StateObject private var viewModel = ViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Picker("Substance", selection: $viewModel.selectedSubstance) {
                    ForEach(viewModel.sortedSubstances) { sub in
                        Text(sub.nameUnwrapped).tag(sub)
                    }
                }
                Picker("Administration Route", selection: $viewModel.administrationRoute) {
                    ForEach(AdministrationRoute.allCases) { route in
                        Text(route.rawValue).tag(route)
                    }
                }
                DoseView(roaDose: viewModel.roaDose)
                DosePicker(
                    roaDose: viewModel.roaDose,
                    doseMaybe: $viewModel.dosePerUnit,
                    selectedUnits: $viewModel.selectedUnitDummy
                )
            }
            .navigationTitle("Add Component")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
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

struct AddComponentView_Previews: PreviewProvider {
    static var previews: some View {
        AddComponentView(addComponent: {_ in})
    }
}
