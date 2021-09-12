import SwiftUI

struct IngestionObserverView: View {

    @ObservedObject var experience: Experience

    @FetchRequest private var ingestions: FetchedResults<Ingestion>

    @AppStorage(PersistenceController.isShowingWatchFaceKey) var isShowingWatchFace: Bool = true

    init(experience: Experience) {
        self.experience = experience
        _ingestions = FetchRequest(
            entity: Ingestion.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Ingestion.time, ascending: false)
            ],
            predicate: NSPredicate(format: "experience == %@", experience)
        )
    }

    var body: some View {
        Group {
            if isShowingWatchFace {
                WatchFaceView(ingestions: ingestions.reversed())
            } else {
                GaugesView(ingestions: ingestions.reversed())
            }
        }
    }
}
