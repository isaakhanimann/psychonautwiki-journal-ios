// Copyright (c) 2022. Isaak Hanimann.
// This file is part of PsychonautWiki Journal.
//
// PsychonautWiki Journal is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public Licence as published by
// the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// PsychonautWiki Journal is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PsychonautWiki Journal. If not, see https://www.gnu.org/licenses/gpl-3.0.en.html.

import CoreData
import Foundation

struct Substance: Decodable, Identifiable, Hashable {
    static func == (lhs: Substance, rhs: Substance) -> Bool {
        lhs.name == rhs.name
    }

    var id: String {
        name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    let name: String
    let url: URL
    let commonNames: [String]
    let isApproved: Bool
    let tolerance: Tolerance?
    let crossTolerances: [String]
    let addictionPotential: String?
    let toxicities: [String]
    let categories: [String]
    let interactions: Interactions?
    let roas: [Roa]
    let summary: String?
    let effectsSummary: String?
    let dosageRemark: String?
    let generalRisks: String?
    let longtermRisks: String?
    let saferUse: [String]

    enum CodingKeys: String, CodingKey {
        case name
        case url
        case commonNames
        case isApproved
        case tolerance
        case crossTolerances
        case addictionPotential
        case toxicities
        case categories
        case interactions
        case roas
        case summary
        case effectsSummary
        case dosageRemark
        case generalRisks
        case longtermRisks
        case saferUse
    }

    init(from decoder: Decoder) throws {
        // need custom decoder because some keys might be missing so we need decodeIfPresent
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        url = try container.decode(URL.self, forKey: .url)
        commonNames = try container.decode([String].self, forKey: .commonNames)
        isApproved = try container.decode(Bool.self, forKey: .isApproved)
        roas = try container.decode([Roa].self, forKey: .roas)
        tolerance = try? container.decodeIfPresent(Tolerance.self, forKey: .tolerance)
        crossTolerances = (try? container.decodeIfPresent([String].self, forKey: .crossTolerances)) ?? []
        addictionPotential = try? container.decodeIfPresent(
            String.self,
            forKey: .addictionPotential
        )
        toxicities = (try? container.decodeIfPresent(
            [String].self,
            forKey: .toxicities
        )) ?? []
        categories = (try? container.decodeIfPresent(
            [String].self,
            forKey: .categories
        )) ?? []
        interactions = try? container.decodeIfPresent(Interactions.self, forKey: .interactions)
        summary = try? container.decodeIfPresent(String.self, forKey: .summary)
        effectsSummary = try? container.decodeIfPresent(String.self, forKey: .effectsSummary)
        dosageRemark = try? container.decodeIfPresent(String.self, forKey: .dosageRemark)
        generalRisks = try? container.decodeIfPresent(String.self, forKey: .generalRisks)
        longtermRisks = try? container.decodeIfPresent(String.self, forKey: .longtermRisks)
        saferUse = (try? container.decodeIfPresent([String].self, forKey: .saferUse)) ?? []
    }

    var administrationRoutesUnwrapped: [AdministrationRoute] {
        roas.map { roa in
            roa.name
        }
    }

    func getDuration(for administrationRoute: AdministrationRoute) -> RoaDuration? {
        let filteredRoas = roas.filter { roa in
            roa.name == administrationRoute
        }

        guard let duration = filteredRoas.first?.duration else {
            return nil
        }
        return duration
    }

    func getDose(for administrationRoute: AdministrationRoute?) -> RoaDose? {
        guard let administrationRoute = administrationRoute else {
            return nil
        }
        let filteredRoas = roas.filter { roa in
            roa.name == administrationRoute
        }
        guard let dose = filteredRoas.first?.dose else {
            return nil
        }
        return dose
    }

    var durationInfos: [DurationInfo] {
        roas.compactMap { roa in
            if let duration = roa.duration {
                return DurationInfo(
                    route: roa.name,
                    roaDuration: duration
                )
            } else {
                return nil
            }
        }
    }

    var doseInfos: [DoseInfo] {
        roas.compactMap { roa in
            if let dose = roa.dose {
                return DoseInfo(
                    route: roa.name,
                    roaDose: dose,
                    bioavailability: roa.bioavailability
                )
            } else {
                return nil
            }
        }
    }

    var isHallucinogen: Bool {
        categories.contains("psychedelic") || categories.contains("dissociative") || categories.contains("deliriant") || categories.contains("hallucinogen")
    }
}

struct DurationInfo {
    let route: AdministrationRoute
    let roaDuration: RoaDuration
}

struct DoseInfo {
    let route: AdministrationRoute
    let roaDose: RoaDose
    let bioavailability: RoaRange?
}
