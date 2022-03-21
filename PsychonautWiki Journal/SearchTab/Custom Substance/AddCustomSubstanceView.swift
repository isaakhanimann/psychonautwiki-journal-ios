import SwiftUI

struct AddCustomSubstanceView: View {

    @StateObject private var viewModel = ViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section("Name") {
                    TextField(
                        "Name",
                        text: $viewModel.name,
                        prompt: Text("Custom Substance Name")
                    )
                }
                .headerProminence(.increased)
                Section("Units") {
                    UnitsPicker(units: $viewModel.units)
                }
                .headerProminence(.increased)
                Section("Explanation") {
                    // swiftlint:disable line_length
                    Text("Define a custom substance if the substance you intend to ingest is not covered by the app yet. If you want to define a substance that consists of other substances consider creating a preset instead.")
                        .lineLimit(nil)
                        .foregroundColor(.secondary)
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
