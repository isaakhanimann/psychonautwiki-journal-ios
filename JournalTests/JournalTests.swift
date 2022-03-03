import XCTest
@testable import Journal
import CoreData

class JournalTests: XCTestCase {

    override func setUp() {
        super.setUp()
        PersistenceController.preview.addInitialSubstances()
    }

    override func tearDown() {
        let fetchRequest = Substance.fetchRequest()
        fetchRequest.includesPropertyValues = false
        let substances = (try? PersistenceController.preview.viewContext.fetch(fetchRequest)) ?? []
        for substance in substances {
            PersistenceController.preview.viewContext.delete(substance)
        }
        if PersistenceController.preview.viewContext.hasChanges {
            try? PersistenceController.preview.viewContext.save()
        }
        super.tearDown()
    }

    func testHasOneFile() throws {
        let fetchRequest = SubstancesFile.fetchRequest()
        let files = try PersistenceController.preview.viewContext.fetch(fetchRequest)
        XCTAssertEqual(files.count, 1)
    }

    // swiftlint:disable cyclomatic_complexity
    func testCoreDataAssumptions() throws {
        let fetchRequest = Substance.fetchRequest()
        let substances = try PersistenceController.preview.viewContext.fetch(fetchRequest)
        for substance in substances {
            // uncertain
            for chemical in substance.uncertainChemicalsUnwrapped {
                XCTAssertTrue(chemical.uncertainSubstancesUnwrapped.contains(substance), substance.nameUnwrapped)
            }
            for psych in substance.uncertainPsychoactivesUnwrapped {
                XCTAssertTrue(psych.uncertainSubstancesUnwrapped.contains(substance), substance.nameUnwrapped)
            }
            for unres in substance.uncertainUnresolvedsUnwrapped {
                XCTAssertTrue(unres.uncertainSubstancesUnwrapped.contains(substance), substance.nameUnwrapped)
            }
            for sub in substance.uncertainSubstancesUnwrapped {
                XCTAssertTrue(sub.uncertainSubstancesUnwrapped.contains(substance), substance.nameUnwrapped)
            }
            // unsafe
            for chemical in substance.unsafeChemicalsUnwrapped {
                XCTAssertTrue(chemical.unsafeSubstancesUnwrapped.contains(substance), substance.nameUnwrapped)
            }
            for psych in substance.unsafePsychoactivesUnwrapped {
                XCTAssertTrue(psych.unsafeSubstancesUnwrapped.contains(substance), substance.nameUnwrapped)
            }
            for unres in substance.unsafeUnresolvedsUnwrapped {
                XCTAssertTrue(unres.unsafeSubstancesUnwrapped.contains(substance), substance.nameUnwrapped)
            }
            for sub in substance.unsafeSubstancesUnwrapped {
                XCTAssertTrue(sub.unsafeSubstancesUnwrapped.contains(substance), substance.nameUnwrapped)
            }
            // dangerous
            for chemical in substance.dangerousChemicalsUnwrapped {
                XCTAssertTrue(chemical.dangerousSubstancesUnwrapped.contains(substance), substance.nameUnwrapped)
            }
            for psych in substance.dangerousPsychoactivesUnwrapped {
                XCTAssertTrue(psych.dangerousSubstancesUnwrapped.contains(substance), substance.nameUnwrapped)
            }
            for unres in substance.dangerousUnresolvedsUnwrapped {
                XCTAssertTrue(unres.dangerousSubstancesUnwrapped.contains(substance), substance.nameUnwrapped)
            }
            for sub in substance.dangerousSubstancesUnwrapped {
                XCTAssertTrue(sub.dangerousSubstancesUnwrapped.contains(substance), substance.nameUnwrapped)
            }
        }
    }

    func testLSD() throws {
        let fetchRequest = Substance.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", "LSD")
        let substances = try PersistenceController.preview.viewContext.fetch(fetchRequest)
        XCTAssertEqual(substances.count, 1)
        let lsd = substances.first!
        XCTAssertEqual(lsd.psychoactivesUnwrapped.count, 1)
        XCTAssertEqual(lsd.psychoactivesUnwrapped.first!.name, "Psychedelics")
        XCTAssertEqual(lsd.chemicalsUnwrapped.count, 1)
        XCTAssertEqual(lsd.chemicalsUnwrapped.first!.name, "Lysergamides")
        XCTAssertEqual(lsd.crossToleranceChemicalsUnwrapped.count, 0)
        XCTAssertEqual(lsd.crossToleranceSubstancesUnwrapped.count, 0)
        XCTAssertEqual(lsd.crossTolerancePsychoactivesUnwrapped.count, 1)
        XCTAssertEqual(lsd.crossTolerancePsychoactivesUnwrapped.first!.name, "Psychedelics")
        // uncertain
        XCTAssertEqual(Set(lsd.uncertainSubstancesUnwrapped.map { $0.name }), ["Cannabis"])
        XCTAssertEqual(Set(lsd.uncertainChemicalsUnwrapped.map { $0.name }), [])
        XCTAssertEqual(Set(lsd.uncertainPsychoactivesUnwrapped.map { $0.name }), ["Stimulants"])
        XCTAssertEqual(Set(lsd.uncertainUnresolvedsUnwrapped.map { $0.name }), [])
        // unsafe
        XCTAssertEqual(Set(lsd.unsafeSubstancesUnwrapped.map { $0.name }), ["Tramadol"])
        XCTAssertEqual(Set(lsd.unsafeChemicalsUnwrapped.map { $0.name }), [])
        XCTAssertEqual(Set(lsd.unsafePsychoactivesUnwrapped.map { $0.name }), ["Deliriant"])
        XCTAssertEqual(Set(lsd.unsafeUnresolvedsUnwrapped.map { $0.name }), ["Tricyclic Antidepressants", "Ritonavir"])
        // dangerous
        XCTAssertEqual(Set(lsd.dangerousSubstancesUnwrapped.map { $0.name }), [])
        XCTAssertEqual(Set(lsd.dangerousChemicalsUnwrapped.map { $0.name }), [])
        XCTAssertEqual(Set(lsd.dangerousPsychoactivesUnwrapped.map { $0.name }), [])
        XCTAssertEqual(Set(lsd.dangerousUnresolvedsUnwrapped.map { $0.name }), [])
    }
}
