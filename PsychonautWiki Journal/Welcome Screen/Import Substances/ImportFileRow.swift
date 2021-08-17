import SwiftUI

struct ImportFileRow: View {

    let substancesLink: SubstancesLink

    @State private var downloadFileState = DownloadFileState.notStarted

    var body: some View {
        Group {
            switch downloadFileState {
            case .notStarted:
                Button(action: {
                    tryToUseSubstances(substancesLink: substancesLink)
                }, label: {
                    Label(substancesLink.name, systemImage: "square.and.arrow.down")
                        .foregroundColor(.accentColor)
                })
            case .downloading:
                HStack {
                    ProgressView()
                    Spacer().frame(maxWidth: 20)
                    Text("Fetching \(substancesLink.name)...")
                        .foregroundColor(.secondary)
                }
            case .error(let message):
                Text(message)
                    .foregroundColor(.red)
            case .success:
                Label("\(substancesLink.name) imported", systemImage: "checkmark")
                    .foregroundColor(.green)
            }
        }
    }

    enum DownloadFileState {
        case notStarted
        case downloading
        case error(message: String)
        case success
    }

    func tryToUseSubstances(substancesLink: SubstancesLink) {
        self.downloadFileState = .downloading
        let request = URLRequest(url: substancesLink.downloadURL)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let errorUnwrapped = error {
                print(errorUnwrapped.localizedDescription)
                DispatchQueue.main.async {
                    self.downloadFileState = .error(message: "Failed to open substance url")
                }
                return
            }
            if let dataUnwrapped = data {
                self.decodeAndSaveFileMaybe(from: dataUnwrapped, with: substancesLink.name)
            } else {
                DispatchQueue.main.async {
                    self.downloadFileState = .error(message: "Failed to load data")
                }
            }
        }.resume()
    }

    private func decodeAndSaveFileMaybe(from data: Data, with filename: String) {
        do {
            try SubstanceDecoder.decodeAndSaveFile(
                from: data,
                with: filename,
                selectFile: false,
                markFileAsNew: false
            )
            DispatchQueue.main.async {
                self.downloadFileState = .success
            }
        } catch {
            DispatchQueue.main.async {
                self.downloadFileState = .error(message: "Failed to decode substances")
            }
        }
    }
}
