import SwiftUI

struct HomeTab: View {

    @ObservedObject var activeExperience: Experience

    var body: some View {
        Circle()
    }
}

struct HomeTab_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        HomeTab(activeExperience: helper.experiences.first!)
    }
}
