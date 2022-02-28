import SwiftUI

struct IngestionObserverView: View {

    @FetchRequest private var ingestions: FetchedResults<Ingestion>

    init(experience: Experience) {
        _ingestions = FetchRequest(
            entity: Ingestion.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Ingestion.time, ascending: false)
            ],
            predicate: NSPredicate(format: "experience == %@", experience)
        )
    }

    var body: some View {
        WatchFaceView(
            ingestions: ingestions.reversed(),
            clockHandStyle: .hourAndMinute,
            timeStyle: .currentTime
        )
    }
}
