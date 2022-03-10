import XCTest
@testable import Journal
import CoreData

class PsychoactiveTests: XCTestCase {

    override func setUp() {
        super.setUp()
        PersistenceController.preview.addInitialSubstances()
    }

    override func tearDown() {
        PersistenceController.preview.deleteAllSubstancesWithSave()
        super.tearDown()
    }

    func testImportantExist() throws {
        let psychoactives = try getAllPsychoactives()
        let names = Set(psychoactives.map { $0.nameUnwrapped })
        XCTAssertTrue(names.contains("Psychedelics"))
        XCTAssertTrue(names.contains("Cannabinoids"))
        XCTAssertTrue(names.contains("Dissociatives"))
        XCTAssertTrue(names.contains("Deliriants"))
        XCTAssertTrue(names.contains("Depressants"))
        XCTAssertTrue(names.contains("Stimulants"))
        XCTAssertTrue(names.contains("Entactogens"))
        XCTAssertTrue(names.contains("Nootropics"))
        XCTAssertTrue(names.contains("Antipsychotics"))
    }

    private func getAllPsychoactives() throws -> [PsychoactiveClass] {
        let fetchRequest = PsychoactiveClass.fetchRequest()
        return try PersistenceController.preview.viewContext.fetch(fetchRequest)
    }

    func testNamesEndWithS() throws {
        let psychoactives = try getAllPsychoactives()
        let names = Set(psychoactives.map { $0.nameUnwrapped })
        for name in names {
            XCTAssertTrue(name.hasSuffix("s"), "\(name) doesn't have suffix s")
        }
    }

    func testURLs() throws {
        let psychoactives = try getAllPsychoactives()
        for psychoactive in psychoactives {
            let name = psychoactive.nameUnwrapped
            if !["Eugeroics", "Miscellaneous", "Oneirogens"].contains(name) {
                XCTAssertTrue(psychoactive.url != nil, "\(name) has no url")
            }
        }
    }
}
