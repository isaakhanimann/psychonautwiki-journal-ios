import SwiftUI

struct AddPresetView: View {

    @StateObject private var viewModel = ViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                TextField("Preset Name", text: $viewModel.presetName)
                UnitsPicker(units: $viewModel.units)

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
            }
            .navigationTitle("Add Preset")
            .sheet(isPresented: $viewModel.isShowingAddComponentSheet) {
                AddComponentView(
                    addComponent: viewModel.addComponentToList
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
