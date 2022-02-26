import Foundation
import CoreData

enum ConversionError: Error {
    case failedToConvertDataToJSON
}

func decodeSubstancesFile(
    from data: Data,
    with context: NSManagedObjectContext
) throws -> SubstancesFile {
    let decoder = JSONDecoder()
    decoder.userInfo[CodingUserInfoKey.managedObjectContext] = context
    decoder.dateDecodingStrategy = .deferredToDate
    decoder.keyDecodingStrategy = .useDefaultKeys
    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
          let fileObject = json["data"] else {
        throw ConversionError.failedToConvertDataToJSON
    }
    let fileData = try JSONSerialization.data(withJSONObject: fileObject)
    return try decoder.decode(SubstancesFile.self, from: fileData)
}

enum RequestError: Error {
    case badURL
    case noData
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