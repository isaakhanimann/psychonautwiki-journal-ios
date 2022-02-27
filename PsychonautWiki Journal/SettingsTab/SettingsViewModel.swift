import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var isShowingErrorAlert = false
    @Published var alertMessage = ""
    @Published var isFetching = false
    @Published var substancesFile: SubstancesFile?

    private var cancellable: AnyCancellable?

    // swiftlint:disable line_length
    init(filePublisher: AnyPublisher<SubstancesFile?, Never> = SubstanceFilePublisher.shared.file.eraseToAnyPublisher()) {
        cancellable = filePublisher.sink { file in
            self.substancesFile = file
        }
    }

    func fetchNewSubstances() {
        isFetching = true
        performPsychonautWikiAPIRequest { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.alertMessage = "Request to PsychonautWiki API failed."
                    self.isShowingErrorAlert.toggle()
                    self.isFetching = false
                }
            case .success(let data):
                self.tryToDecodeData(data: data)
            }
        }
    }

    private func tryToDecodeData(data: Data) {
        do {
            try PersistenceController.shared.decodeAndSaveFile(from: data)
        } catch {
            DispatchQueue.main.async {
                self.alertMessage = "Not enough substances could be parsed."
                self.isShowingErrorAlert.toggle()
            }
        }
        DispatchQueue.main.async {
            self.isFetching = false
        }
    }

}
