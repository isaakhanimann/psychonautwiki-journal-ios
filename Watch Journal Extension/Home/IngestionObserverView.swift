import SwiftUI

struct IngestionObserverView: View {

    @ObservedObject var experience: Experience

    @FetchRequest private var ingestions: FetchedResults<Ingestion>

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
        WatchFaceView(ingestions: ingestions.reversed())
    }
}
