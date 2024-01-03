// Copyright (c) 2023. Isaak Hanimann.
// This file is part of JournalTests.
//
// JournalTests is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public Licence as published by
// the Free Software Foundation, either version 3 of the License, or (at
// your option) any later version.
//
// JournalTests is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with JournalTests. If not, see https://www.gnu.org/licenses/gpl-3.0.en.html.

@testable import Journal
import XCTest

final class InteractionTests: XCTestCase {
    func testInteractions() throws {
        XCTAssertFalse(InteractionChecker.hasXAndMatches(wordWithX: "Dox", matchWith: "Oxycodone"))
        XCTAssertEqual(InteractionChecker.getInteractionTypeBetween(aName: "MDMA", bName: "Tramadol"), .dangerous)
        XCTAssertEqual(InteractionChecker.getInteractionTypeBetween(aName: "MDMA", bName: "Alcohol"), .uncertain)
        XCTAssertEqual(InteractionChecker.getInteractionTypeBetween(aName: "MDMA", bName: "Caffeine"), .uncertain)
        XCTAssertEqual(InteractionChecker.getInteractionTypeBetween(aName: "Nothing", bName: "MDMA"), nil)
        XCTAssertEqual(InteractionChecker.getInteractionTypeBetween(aName: "Oxycodone", bName: "MDMA"), nil)
        XCTAssertEqual(InteractionChecker.getInteractionTypeBetween(aName: "Amphetamine", bName: "Dextromethorphan"), .unsafe)
        XCTAssertEqual(InteractionChecker.getInteractionTypeBetween(aName: "Amphetamine", bName: "DOM"), .unsafe)
        XCTAssertEqual(InteractionChecker.getInteractionTypeBetween(aName: "Heroin", bName: "Cocaine"), .dangerous)
        XCTAssertEqual(InteractionChecker.getInteractionTypeBetween(aName: "Heroin", bName: "Grapefruit"), .dangerous)
        XCTAssertEqual(InteractionChecker.getInteractionTypeBetween(aName: "Heroin", bName: "Nothing"), nil)
        XCTAssertEqual(InteractionChecker.getInteractionTypeBetween(aName: "Pregabalin", bName: "LSD"), nil)
        XCTAssertEqual(InteractionChecker.getInteractionTypeBetween(aName: "Grapefruit", bName: "Heroin"), .dangerous)
    }
}
