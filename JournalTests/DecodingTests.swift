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

import XCTest
@testable import Journal
import CoreData

class DecodingTests: XCTestCase {

    func testRoaDecoding() async throws {
        let data = getInitialData()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .deferredToDate
        decoder.keyDecodingStrategy = .useDefaultKeys
        do {
            let roa = try decoder.decode(RoaDecodable.self, from: data)
            print(roa)
        } catch {
            fatalError(String(describing: error))
        }

    }

    private func getInitialData() -> Data {
        let testBundle = Bundle(for: type(of: self))
        guard let url = testBundle.url(forResource: "Roa", withExtension: "json") else {
            fatalError("Failed to locate Roa.json.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load Roa.json.")
        }
        return data
    }

}



struct RoaDecodable: Decodable {

    let roas: [Roa]

    enum CodingKeys: String, CodingKey {
        case roas
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.roas = try container.decode([Roa].self, forKey: .roas)
    }
}
