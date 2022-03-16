import CoreData
import UIKit

func playHapticFeedback() {
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    impactMed.impactOccurred()
}

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

func refreshSubstances() async throws {
    let data = try await getPsychonautWikiData()
    try await PersistenceController.shared.decodeAndSaveFile(from: data)
}

enum RequestError: Error {
    case invalidServerResponse
}

func getPsychonautWikiData() async throws -> Data {
    let request = try getURLRequest()
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
          throw RequestError.invalidServerResponse
        }
    return data
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

func getMaxEndTime(for ingestions: [Ingestion]) -> Date? {
    guard let firstIngestion = ingestions.first else {return nil}
    var endOfGraphTime = firstIngestion.timeUnwrapped
    for ingestion in ingestions {
        guard let duration = ingestion.substance?
                .getDuration(for: ingestion.administrationRouteUnwrapped) else {return nil}
        guard let onset = duration.onset?.maxSec else {return nil}
        guard let comeup = duration.comeup?.maxSec else {return nil}
        guard let peak = duration.peak?.maxSec else {return nil}
        guard let offset = duration.offset?.maxSec else {return nil}
        // Choose the latest possible offset to make sure that the graph fits all ingestions
        let offsetEnd = onset
            + comeup
            + peak
            + offset
        let maybeNewEndTime = ingestion.timeUnwrapped.addingTimeInterval(offsetEnd)
        if endOfGraphTime.distance(to: maybeNewEndTime) > 0 {
            endOfGraphTime = maybeNewEndTime
        }
    }
    return endOfGraphTime
}
