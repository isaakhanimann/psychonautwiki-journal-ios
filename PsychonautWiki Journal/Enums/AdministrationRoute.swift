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

    var displayString: String {
        switch self {
        case .oral:
            return "oral (swallowed)"
        case .sublingual:
            return "sublingual (under the tongue)"
        case .buccal:
            return "buccal (between gums and cheek)"
        case .insufflated:
            return "insufflated (sniffed)"
        case .rectal:
            return "rectal"
        case .transdermal:
            return "transdermal (through skin)"
        case .subcutaneous:
            return "subcutaneous (injected)"
        case .intramuscular:
            return "intramuscular (injected)"
        case .intravenous:
            return "intravenous (injected)"
        case .smoked:
            return "smoked"
        case .inhaled:
            return "inhaled"
        }
    }

    var color: Color {
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
            return .green
        case .subcutaneous:
            return .mint
        case .intramuscular:
            return .brown
        case .intravenous:
            return .red
        case .smoked:
            return .yellow
        case .inhaled:
            return .purple
        }
    }
}


