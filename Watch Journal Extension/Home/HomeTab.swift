import SwiftUI

struct HomeTab: View {

    @ObservedObject var activeExperience: Experience

    var body: some View {
        AllLayersView(ingestions: activeExperience.sortedIngestionsUnwrapped)
    }
}

struct HomeTab_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        HomeTab(activeExperience: helper.experiences.first!)
    }
}
