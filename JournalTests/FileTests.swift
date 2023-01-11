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

class FileTests: XCTestCase {

    override func setUp() {
        super.setUp()
        PersistenceController.preview.addInitialSubstances()
    }

    override func tearDown() {
        PersistenceController.preview.deleteAllSubstancesWithSave()
        super.tearDown()
    }

    func testHasOneFile() throws {
        let fetchRequest = SubstancesFile.fetchRequest()
        let files = try PersistenceController.preview.viewContext.fetch(fetchRequest)
        XCTAssertEqual(files.count, 1)
    }

    func testHasOneFileAfterDecoding() async throws {
        let fileData = getInitialData()
        try await PersistenceController.preview.decodeAndSaveFile(from: fileData)
        let fetchRequest = SubstancesFile.fetchRequest()
        let files = try PersistenceController.preview.viewContext.fetch(fetchRequest)
        XCTAssertEqual(files.count, 1)
    }

}
