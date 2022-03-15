import SwiftUI

struct AddPresetView: View {

    @StateObject private var viewModel = ViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("Preset Name", text: $viewModel.presetName)
                }
                .headerProminence(.increased)
                Section(header: Text("Units")) {
                    UnitsPicker(units: $viewModel.units)
                }
                .headerProminence(.increased)
                Section("1 \(viewModel.units ?? "") contains") {
                    ForEach(viewModel.components) { com in
                        HStack {
                            Text(com.substance.nameUnwrapped)
                            Spacer()
                            let units = com.substance.getDose(for: com.administrationRoute)?.unitsUnwrapped ?? ""
                            Text("\(com.dose.formatted()) \(units) \(com.administrationRoute.rawValue)")
                                .foregroundColor(.secondary)
                        }
                    }
                    Button {
                        viewModel.isShowingAddComponentSheet.toggle()
                    } label: {
                        Label("Add Component", systemImage: "plus")
                    }
                }
                .headerProminence(.increased)
            }
            .navigationTitle("Add Preset")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isEverythingNeededDefined {
                        Button("Done") {
                            viewModel.savePreset()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingAddComponentSheet) {
                AddComponentView(
                    addComponent: viewModel.addComponentToList,
                    presetName: $viewModel.presetName,
                    presetUnit: $viewModel.units
                )
            }
        }
    }
}

struct AddPresetView_Previews: PreviewProvider {
    static var previews: some View {
        AddPresetView()
    }
}
