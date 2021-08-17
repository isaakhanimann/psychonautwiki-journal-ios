import SwiftUI
import CoreData

struct SelectNewFileView: View {

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: [ NSSortDescriptor(keyPath: \SubstancesFile.creationDate, ascending: false) ]
    ) var files: FetchedResults<SubstancesFile>
    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "isNew == true")
    ) var newFile: FetchedResults<SubstancesFile>
    @AppStorage(
        PersistenceController.isThereANewFileKey,
        store: UserDefaults(suiteName: PersistenceController.appGroupName)
    ) var isThereANewFile: Bool = false

    @Environment(\.managedObjectContext) var moc

    @State private var isShowingInteractionsView = false
    @State private var hasSelectedFile = false

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 30) {
                if let newFileUnwrapped = newFile.first {
                    Text("Substances Import Successful")
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                        .foregroundColor(.green)
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.green)
                        .frame(width: 70, height: 70)
                    if hasSelectedFile {
                        Text("New substances are in use")
                    } else {
                        Text("Do you want to use the new substances?")
                            .lineLimit(2)
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Text(newFileUnwrapped.filenameUnwrapped)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        Spacer()
                        Button("Yes", action: selectFileAndShowNextSheet)
                            .buttonStyle(PrimaryButtonStyle())
                            .font(.title2)
                    }
                    NavigationLink(
                        destination: ChooseGeneralInteractionsView(file: newFile.first!, dismiss: dismiss),
                        isActive: $isShowingInteractionsView,
                        label: {
                            Text(hasSelectedFile ? "Next" : "No")
                        }
                    )
                    .isDetailLink(false)
                } else {
                    Text("There is no new file")
                }
            }
            .padding()
        }
        .currentDeviceNavigationViewStyle()
    }

    private func dismiss() {
        newFile.first!.isNew = false
        if moc.hasChanges {
            try? moc.save()
        }
        isThereANewFile = false
    }

    private func selectFileAndShowNextSheet() {
        guard let newFileUnwrapped = newFile.first else {
            fatalError("Should only be able to call this function if there is no new file")
        }

        for file in files {
            file.isSelected = false
        }
        newFileUnwrapped.isSelected = true
        if moc.hasChanges {
            try? moc.save()
        }
        hasSelectedFile = true
        isShowingInteractionsView = true
    }
}
