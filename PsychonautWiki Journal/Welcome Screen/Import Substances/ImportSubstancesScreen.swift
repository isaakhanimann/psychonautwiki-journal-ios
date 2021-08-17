import SwiftUI

struct ImportSubstancesScreen: View {

    @AppStorage(PersistenceController.hasBeenSetupBeforeKey) var hasBeenSetupBefore: Bool = false
    @AppStorage(PersistenceController.hasAcceptedImportKey) var hasAcceptedImport: Bool = false

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: [ NSSortDescriptor(keyPath: \SubstancesFile.creationDate, ascending: false) ],
        predicate: NSPredicate(format: "isNew == false")
    ) var files: FetchedResults<SubstancesFile>

    @Environment(\.managedObjectContext) var moc

    @State private var isShowingActionSheet = false
    @State private var selectedFile: SubstancesFile?
    @State private var isShowingInteractions = false

    var body: some View {
        Group {
            if hasAcceptedImport {
                VStack(spacing: 20) {

                    ImportSubstancesScrollView()

                    if let selectedFileUnwrapped = selectedFile {
                        NavigationLink(
                            destination: ChooseGeneralInteractionsView(file: selectedFileUnwrapped, dismiss: dismiss),
                            isActive: $isShowingInteractions,
                            label: {
                                EmptyView()
                            })
                    }
                    Text("You can also import substances later in Settings")
                        .font(.footnote)
                    Button("Done", action: donePressed)
                        .buttonStyle(PrimaryButtonStyle())
                        .actionSheet(isPresented: $isShowingActionSheet) {
                            ActionSheet(
                                title: Text("Select Substances"),
                                message: Text("Which substance definitions do you want to use?"),
                                buttons: actionSheetButtons
                            )
                        }
                }
                .padding()
            } else {
                ImportDisclaimerView(onDontImport: addSampleSubstancesAndDismiss, understandPressed: understandPressed)
                    .transition(.move(edge: .leading))
            }

        }
        .navigationBarHidden(true)
    }

    private func understandPressed() {
        withAnimation {
            hasAcceptedImport.toggle()
        }
    }

    private func donePressed() {
        if files.isEmpty {
            addSampleSubstancesAndDismiss()
        } else if files.count == 1 {
            selectFile(fileToSelect: files.first!)
            showNext(file: files.first!)
        } else {
            isShowingActionSheet.toggle()
        }
    }

    private func showNext(file: SubstancesFile) {
        selectedFile = file
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isShowingInteractions.toggle()
        }
    }

    private var actionSheetButtons: [ActionSheet.Button] {
        var buttons = [ActionSheet.Button]()
        for file in files {
            let button = ActionSheet.Button.default(Text(file.filenameUnwrapped)) {
                self.selectFile(fileToSelect: file)
                showNext(file: file)
            }
            buttons.append(button)
        }
        return buttons
    }

    private func selectFile(fileToSelect: SubstancesFile) {
        for file in files {
            file.isSelected = false
        }
        fileToSelect.isSelected = true
        if moc.hasChanges {
            try? moc.save()
        }
    }

    private func addSampleSubstancesAndDismiss() {
        let fileName = "Sample Substances"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            fatalError("Failed to locate \(fileName) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(fileName) from bundle.")
        }

        do {
            try SubstanceDecoder.decodeAndSaveFile(
                from: data,
                with: fileName,
                selectFile: true,
                markFileAsNew: false
            )
        } catch {
            fatalError("Failed to decode \(fileName) from bundle")
        }

        hasBeenSetupBefore = true
    }

    private func dismiss() {
        hasBeenSetupBefore = true
    }
}

struct ImportSubstancesScreen_Previews: PreviewProvider {

    static var previews: some View {
        ImportSubstancesScreen()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
