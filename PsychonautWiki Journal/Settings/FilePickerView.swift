import SwiftUI

struct FilePickerView: View {

    @Environment(\.presentationMode) var presentationMode

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: [ NSSortDescriptor(keyPath: \SubstancesFile.creationDate, ascending: false) ]
    ) var files: FetchedResults<SubstancesFile>
    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "isSelected == true")
    ) var selectedFile: FetchedResults<SubstancesFile>

    var body: some View {
        List {
            ForEach(files) { file in
                getRowContent(for: file)
            }
        }
        .listStyle(PlainListStyle())
    }

    private func getRowContent(for currentFile: SubstancesFile) -> some View {
        Button {
            for file in files {
                file.isSelected = false
            }
            currentFile.isSelected = true
            presentationMode.wrappedValue.dismiss()
        } label: {
            HStack {
                Text(currentFile.filenameUnwrapped)
                Spacer()
                if currentFile.isSelected {
                    Image(systemName: "checkmark")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
        }
    }
}
