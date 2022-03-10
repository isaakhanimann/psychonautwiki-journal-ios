import Foundation
import Combine

extension SettingsTab {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var isShowingErrorAlert = false
        @Published var isFetching = false
        @Published var substancesFile: SubstancesFile?

        private var cancellable: AnyCancellable?

        // swiftlint:disable line_length
        init(filePublisher: AnyPublisher<SubstancesFile?, Never> = SubstanceFilePublisher.shared.file.eraseToAnyPublisher()) {
            cancellable = filePublisher.sink { file in
                self.substancesFile = file
            }
        }

        func fetchNewSubstances() async {
            isFetching = true
            do {
                let data = try await getPsychonautWikiData()
                try await PersistenceController.shared.decodeAndSaveFile(from: data)
            } catch {
                self.isShowingErrorAlert = true
            }
            self.isFetching = false
        }

        func resetSubstances() async {
            isFetching = true
            await PersistenceController.shared.resetAllSubstancesToInitialAndSave()
            isFetching = false
        }
    }
}
