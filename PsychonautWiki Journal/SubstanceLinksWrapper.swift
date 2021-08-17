import Foundation

class SubstanceLinksWrapper: ObservableObject {

    @Published var downloadLinkState = DownloadLinkState.downloading

    enum DownloadLinkState {
        case downloading
        case error(message: String)
        case success(links: [SubstancesLink])
    }

    func downloadLinks() {

        guard let downloadURL = URL(
            string: "https://drive.google.com/uc?export=download&id=1An4I3rB60h8E5S3SpCrbzLD5sCX2J8zU"
        ) else {
            self.downloadLinkState = .error(message: "Could not get file to download links")
            return
        }
        let request = URLRequest(url: downloadURL)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let errorUnwrapped = error {
                print(errorUnwrapped.localizedDescription)
                DispatchQueue.main.async {
                    self.downloadLinkState = .error(message: "Failed to open url")
                }
                return
            }
            if let dataUnwrapped = data {
                self.decodeLinksMaybe(from: dataUnwrapped)
            } else {
                DispatchQueue.main.async {
                    self.downloadLinkState = .error(message: "Failed to load data")
                }
            }
        }.resume()
    }

    private func decodeLinksMaybe(from data: Data) {
        do {
            let links = try decodeLinks(from: data)
            DispatchQueue.main.async {
                if links.isEmpty {
                    self.downloadLinkState = .error(message: "There are no linked files")
                } else {
                    self.downloadLinkState = .success(links: links)
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.downloadLinkState = .error(message: "Failed to decode substance links")
            }
        }
    }

    private func decodeLinks(from data: Data) throws -> [SubstancesLink] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys

        return try decoder.decode([SubstancesLink].self, from: data)
    }
}
