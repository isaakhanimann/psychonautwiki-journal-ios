import Foundation

struct PsychonautWikiAPIController {

    static func fetchAndSaveNewSubstancesAndDeleteOldOnes(oldFile: SubstancesFile) {
        PsychonautWikiAPIController.performRequest { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let data):
                try? SubstanceDecoder.decodeAndSaveFile(
                    from: data,
                    creationDate: Date(),
                    earlierFileToDelete: oldFile
                )
            }
        }
    }

    static private let url = URL(string: "https://api.psychonautwiki.org/")!

    enum RequestError: Error {
        case badURL
        case noData
    }

    static func performRequest(completion: @escaping (Result<Data, RequestError>) -> Void) {

        guard let request = try? getURLRequest() else {
            completion(.failure(.badURL))
            return
        }

        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if error != nil {
                completion(.failure(.badURL))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            completion(.success(data))
        }.resume()

    }

    // swiftlint:disable function_body_length
    static private func getURLRequest() throws -> URLRequest {

        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let query = """
                        query AllSubstances {
                          substances(limit: 9999) {
                            name
                            class {
                              psychoactive
                            }
                            url
                            roas {
                              name
                              dose {
                                units
                                threshold
                                light {
                                  min
                                  max
                                }
                                common {
                                  min
                                  max
                                }
                                strong {
                                  min
                                  max
                                }
                                heavy
                              }
                              duration {
                                onset {
                                  min
                                  max
                                  units
                                }
                                comeup {
                                  min
                                  max
                                  units
                                }
                                peak {
                                  min
                                  max
                                  units
                                }
                                offset {
                                  min
                                  max
                                  units
                                }
                              }
                            }
                            unsafeInteractions {
                              name
                            }
                            dangerousInteractions {
                              name
                            }
                          }
                        }
                    """

        struct HTTPBody: Encodable {
            var query: String
        }

        request.httpBody = try JSONEncoder().encode(HTTPBody(query: query))

        return request
    }
}