import XCTest
@testable import Journal
import CoreData

class JournalTests: XCTestCase {

    var persistenceController: PersistenceController!

    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController.preview
        persistenceController.addInitialSubstances()
    }

    func testHasOneFile() throws {
        let fetchRequest = SubstancesFile.fetchRequest()
        let files = try persistenceController.viewContext.fetch(fetchRequest)
        XCTAssertEqual(files.count, 1)
    }
}
