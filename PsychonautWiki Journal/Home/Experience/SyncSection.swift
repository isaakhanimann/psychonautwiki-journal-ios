import SwiftUI

struct SyncSection: View {

    let experience: Experience
    @EnvironmentObject var connectivity: Connectivity

    @State private var isShowingSyncingMessageSuccess = false

    var body: some View {
        if isShowingSyncingMessageSuccess {
            VStack(alignment: .leading, spacing: 5) {
                Label("Sync Successfull", systemImage: "checkmark.circle")
                if connectivity.isComplicationEnabled {
                    Text("If necessary reload the complication by tapping on it")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        } else {
            Button(action: {
                connectivity.sendSyncMessageToWatch(with: experience.sortedIngestionsUnwrapped)
                isShowingSyncingMessageSuccess = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    isShowingSyncingMessageSuccess = false
                }
            }, label: {
                Label("Sync to Apple Watch", systemImage: "applewatch")
            })
        }
    }
}

struct SyncSection_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        List {
            SyncSection(experience: helper.experiences.first!)
                .environmentObject(Connectivity())
                .accentColor(Color.blue)
        }
        .listStyle(InsetGroupedListStyle())
    }
}
