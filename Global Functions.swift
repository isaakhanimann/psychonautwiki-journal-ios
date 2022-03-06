import Foundation
import CoreData

enum ConversionError: Error {
    case failedToConvertDataToJSON
}

func getInitialData() -> Data {
    let fileName = "InitialSubstances"
    guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
        fatalError("Failed to locate \(fileName) in bundle.")
    }
    guard let data = try? Data(contentsOf: url) else {
        fatalError("Failed to load \(fileName) from bundle.")
    }
    return data
}

private func getDataForSubstances(from fileData: Data) throws -> Data {
    guard let json = try JSONSerialization.jsonObject(with: fileData, options: []) as? [String: Any],
          let fileObject = json["data"] else {
              throw ConversionError.failedToConvertDataToJSON
          }
    return try JSONSerialization.data(withJSONObject: fileObject)
}

func decodeSubstancesFile(
    from data: Data,
    with context: NSManagedObjectContext
) throws -> SubstancesFile {
    let decoder = JSONDecoder()
    decoder.userInfo[CodingUserInfoKey.managedObjectContext] = context
    decoder.dateDecodingStrategy = .deferredToDate
    decoder.keyDecodingStrategy = .useDefaultKeys
    let dataForSubstances = try getDataForSubstances(from: data)
    return try decoder.decode(SubstancesFile.self, from: dataForSubstances)
}

enum RequestError: Error {
    case badURL
    case noData
}

func refreshSubstances(completion: @escaping () -> Void) {
    performPsychonautWikiAPIRequest { result in
        switch result {
        case .failure(let error):
            print(error.localizedDescription)
            completion()
        case .success(let data):
            Task {
                try? await PersistenceController.shared.decodeAndSaveFile(from: data)
                completion()
            }
        }
    }
}

func performPsychonautWikiAPIRequest(completion: @escaping (Result<Data, RequestError>) -> Void) {
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
private func getURLRequest() throws -> URLRequest {
    var request = URLRequest(url: URL(string: "https://api.psychonautwiki.org/")!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let query = """
                    query AllSubstances {
                      substances(limit: 9999) {
                        name
                        url
                        effects {
                          name
                          url
                        }
                        class {
                          chemical
                          psychoactive
                        }
                        tolerance {
                          full
                          half
                          zero
                        }
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
                            total {
                              min
                              max
                              units
                            }
                            afterglow {
                              min
                              max
                              units
                            }
                          }
                          bioavailability {
                            min
                            max
                          }
                        }
                        summary
                        addictionPotential
                        toxicity
                        crossTolerances
                        uncertainInteractions {
                          name
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
