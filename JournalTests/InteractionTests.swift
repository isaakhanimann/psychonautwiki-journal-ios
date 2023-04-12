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

import XCTest
@testable import Journal

final class InteractionTests: XCTestCase {

    func testInteractions() throws {
        XCTAssertFalse(InteractionChecker.checkIfWildCardMatch(wordWithXToReplace: "Dox", matchWith: "Oxycodone"))
        XCTAssertEqual(InteractionChecker.getInteractionBetween(aName: "MDMA", bName: "Tramadol"), Interaction(aName: "MDMA", bName: "Tramadol", interactionType: .dangerous))
        XCTAssertEqual(InteractionChecker.getInteractionBetween(aName: "MDMA", bName: "Alcohol"), Interaction(aName: "MDMA", bName: "Alcohol", interactionType: .dangerous))
        XCTAssertEqual(InteractionChecker.getInteractionBetween(aName: "MDMA", bName: "Caffeine"), Interaction(aName: "MDMA", bName: "Caffeine", interactionType: .uncertain))
        XCTAssertEqual(InteractionChecker.getInteractionBetween(aName: "Nothing", bName: "MDMA"), nil)
        XCTAssertEqual(InteractionChecker.getInteractionBetween(aName: "Oxycodone", bName: "MDMA"), nil)
        XCTAssertEqual(InteractionChecker.getInteractionBetween(aName: "Amphetamine", bName: "Dextomethorphan"), Interaction(aName: "Amphetamine", bName: "Dextomethorphan", interactionType: .unsafe))
        XCTAssertEqual(InteractionChecker.getInteractionBetween(aName: "Amphetamine", bName: "DOM"), Interaction(aName: "Amphetamine", bName: "DOM", interactionType: .unsafe))
        XCTAssertEqual(InteractionChecker.getInteractionBetween(aName: "Heroin", bName: "Cocaine"), Interaction(aName: "Heroin", bName: "Cocaine", interactionType: .dangerous))
        XCTAssertEqual(InteractionChecker.getInteractionBetween(aName: "Heroin", bName: "Grapefruit"), Interaction(aName: "Heroin", bName: "Grapefruit", interactionType: .dangerous))
        XCTAssertEqual(InteractionChecker.getInteractionBetween(aName: "Heroin", bName: "Nothing"), nil)
        XCTAssertEqual(InteractionChecker.getInteractionBetween(aName: "MDMA", bName: "Alcohol"), Interaction(aName: "MDMA", bName: "Alcohol", interactionType: .uncertain))
    }

}
