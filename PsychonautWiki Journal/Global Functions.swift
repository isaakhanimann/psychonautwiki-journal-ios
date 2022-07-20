import CoreData
import UIKit

func playHapticFeedback() {
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    impactMed.impactOccurred()
}

func getCurrentAppVersion() -> String {
    // swiftlint:disable force_cast
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
}

enum ConversionError: Error {
    case failedToConvertDataToJSON
}

let namesOfUncontrolledSubstances = [
    "Caffeine",
    "Myristicin",
    "Choline Bitartrate",
    "Citicoline"
]

func getOkSubstances(substancesToFilter: [Substance], isEyeOpen: Bool) -> [Substance] {
    if isEyeOpen {
        return substancesToFilter
    } else {
        return substancesToFilter.filter { sub in
            namesOfUncontrolledSubstances.contains(sub.name)
        }
    }
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
