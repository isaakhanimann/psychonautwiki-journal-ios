import Foundation

extension ExperienceView {
    class ViewModel: ObservableObject {
        var experience: Experience?
        @Published var selectedTitle = "" {
            didSet {
                experience?.title = selectedTitle
            }
        }
        @Published var isShowingAddIngestionSheet = false
        @Published var writtenText = "" {
            didSet {
                experience?.text = writtenText
            }
        }

        init() {}

        func initialize(experience: Experience) {
            self.experience = experience
            self.selectedTitle = experience.titleUnwrapped
            self.writtenText = experience.textUnwrapped
        }
    }
}
