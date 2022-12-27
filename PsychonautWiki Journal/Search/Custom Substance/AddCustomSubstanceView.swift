import SwiftUI

struct AddCustomSubstanceView: View {

    @StateObject private var viewModel = ViewModel()
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section("Name") {
                    TextField(
                        "Name",
                        text: $viewModel.name,
                        prompt: Text("Enter Name")
                    )
                    .disableAutocorrection(true)
                }
                Section("Description") {
                    TextField(
                        "Description",
                        text: $viewModel.name,
                        prompt: Text("Enter Description")
                    )
                    .disableAutocorrection(true)
                }
                Section("Units") {
                    UnitsPicker(units: $viewModel.units)
                }
            }
            .navigationTitle("Create Custom")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isEverythingNeededDefined {
                        Button("Done") {
                            viewModel.saveCustom()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
}

struct AddCustomSubstanceView_Previews: PreviewProvider {
    static var previews: some View {
        AddCustomSubstanceView()
    }
}
