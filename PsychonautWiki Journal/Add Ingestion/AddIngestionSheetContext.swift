import SwiftUI

class AddIngestionSheetContext: ObservableObject {
    let experience: Experience?

    init(experience: Experience?) {
        self.experience = experience
    }
}
