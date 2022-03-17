import SwiftUI

struct AddCustomSubstanceView: View {

    @StateObject private var viewModel = ViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("Name", text: $viewModel.name)
                }
                .headerProminence(.increased)
                Section(header: Text("Units")) {
                    UnitsPicker(units: $viewModel.units)
                }
                .headerProminence(.increased)
            }
            .navigationTitle("Add Custom Substance")
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
