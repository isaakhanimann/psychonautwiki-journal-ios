import Foundation

struct Feature: Decodable, Identifiable {
    // swiftlint:disable identifier_name
    var id = UUID()
    let title: String
    let description: String
    let image: String
}
