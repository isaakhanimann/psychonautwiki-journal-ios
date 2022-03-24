import SwiftUI

struct AddPresetView: View {

    @StateObject private var viewModel = ViewModel()
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section("Name") {
                    TextField(
                        "Preset Name",
                        text: $viewModel.presetName,
                        prompt: Text("e.g. Coffee")
                    )
                    .disableAutocorrection(true)
                }
                .headerProminence(.increased)
                Section("Units") {
                    UnitsPicker(units: $viewModel.units)
                }
                .headerProminence(.increased)
                let unitOrPlaceHolder = (viewModel.units?.isEmpty ?? true) ? "unit" : (viewModel.units ?? "unit")
                Section("1 \(unitOrPlaceHolder) contains") {
                    ForEach(viewModel.components) { com in
                        HStack {
                            Text(com.substance.nameUnwrapped)
                            Spacer()
                            let units = com.substance.getDose(for: com.administrationRoute)?.unitsUnwrapped ?? ""
                            Text("\(com.dose.formatted()) \(units) \(com.administrationRoute.rawValue)")
                                .foregroundColor(.secondary)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.components.removeAll { iter in
                                    iter.id == com.id
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    Button {
                        viewModel.isShowingAddComponentSheet.toggle()
                    } label: {
                        Label("Add Component", systemImage: "plus")
                    }
                }
                .headerProminence(.increased)
                Section("Explanation") {
                    // swiftlint:disable line_length
                    Text("Components are used to create ingestions. E.g. when you define a preset **Coffee** with a unit **cup** and a component **40mg Caffeine oral per cup**, then when you ingest **1 Coffee** an ingestion with **40mg Caffeine** will be created.")
                        .lineLimit(nil)
                        .foregroundColor(.secondary)
                }
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
