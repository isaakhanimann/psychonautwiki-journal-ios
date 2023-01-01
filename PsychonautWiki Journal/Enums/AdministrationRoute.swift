import Foundation
import SwiftUI

// https://psychonautwiki.org/wiki/Route_of_administration
enum AdministrationRoute: String, Codable, CaseIterable, Identifiable {
    case oral
    case sublingual
    case buccal
    case insufflated
    case rectal
    case transdermal
    case subcutaneous
    case intramuscular
    case intravenous
    case smoked
    case inhaled

    var id: String {
        self.rawValue
    }

    var clarification: String {
        switch self {
        case .oral:
            return "swallowed"
        case .sublingual:
            return "under the tongue"
        case .buccal:
            return "between gums and cheek"
        case .insufflated:
            return "sniffed"
        case .rectal:
            return "up the butt"
        case .transdermal:
            return "through skin"
        case .subcutaneous:
            return "injected below skin"
        case .intramuscular:
            return "injected into muscle"
        case .intravenous:
            return "injected into vein"
        case .smoked:
            return "heating/burning"
        case .inhaled:
            return "vapor/gas"
        }
    }

    var color: SubstanceColor {
        switch self {
        case .oral:
            return .blue
        case .sublingual:
            return .cyan
        case .buccal:
            return .teal
        case .insufflated:
            return .orange
        case .rectal:
            return .pink
        case .transdermal:
            return .yellow
        case .subcutaneous:
            return .mint
        case .intramuscular:
            return .brown
        case .intravenous:
            return .red
        case .smoked:
            return .green
        case .inhaled:
            return .purple
        }
    }
}


