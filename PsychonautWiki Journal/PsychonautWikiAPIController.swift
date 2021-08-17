import Foundation

struct PsychonautWikiAPIController {

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

    struct HTTPBody: Encodable {
        var query: String
    }

    static private func getURLRequest() throws -> URLRequest {

        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let query = """
                        query AllSubstances {
                          substances(limit: 9999) {
                            name
                          }
                        }
                    """

        request.httpBody = try JSONEncoder().encode(HTTPBody(query: query))

        return request
    }
}
