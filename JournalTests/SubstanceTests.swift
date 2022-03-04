import XCTest
@testable import Journal
import CoreData

// swiftlint:disable line_length
class JournalTests: XCTestCase {

    override func setUp() {
        super.setUp()
        PersistenceController.preview.addInitialSubstances()
    }

    override func tearDown() {
        PersistenceController.preview.deleteAllSubstances()
        super.tearDown()
    }

    func testHasEnoughSubstances() throws {
        let substances = try getAllSubstances()
        XCTAssertGreaterThanOrEqual(substances.count, 357)
    }

    private func getAllSubstances() throws -> [Substance] {
        let fetchRequest = Substance.fetchRequest()
        return try PersistenceController.preview.viewContext.fetch(fetchRequest)
    }

    func testHasSubstances() throws {
        let substances = try getAllSubstances()
        let names = Set(substances.map { $0.nameUnwrapped })
        XCTAssertTrue(names.contains("Cocaine"))
        XCTAssertTrue(names.contains("Alcohol"))
        XCTAssertTrue(names.contains("MDMA"))
        XCTAssertTrue(names.contains("Amphetamine"))
        XCTAssertTrue(names.contains("LSD"))
        XCTAssertTrue(names.contains("Heroin"))
        XCTAssertTrue(names.contains("Tramadol"))
        XCTAssertTrue(names.contains("Cannabis"))
        XCTAssertTrue(names.contains("Nicotine"))
        XCTAssertTrue(names.contains("Mescaline"))
        XCTAssertTrue(names.contains("DMT"))
        XCTAssertTrue(names.contains("2C-B"))
        XCTAssertTrue(names.contains("Ketamine"))
        XCTAssertTrue(names.contains("GHB"))
        XCTAssertTrue(names.contains("GBL"))
        XCTAssertTrue(names.contains("DOM"))
        XCTAssertTrue(names.contains("Caffeine"))
        XCTAssertTrue(names.contains("MDA"))
        XCTAssertTrue(names.contains("Mephedrone"))
        XCTAssertTrue(names.contains("Methamphetamine"))
        XCTAssertTrue(names.contains("Nitrous"))
        XCTAssertTrue(names.contains("Psilocybin Mushrooms"))
        XCTAssertTrue(names.contains("Psilocin"))
        XCTAssertTrue(names.contains("Methcathinone"))
    }

    func testSubstancesWhichShouldBeFilteredOut() throws {
        let substances = try getAllSubstances()
        let subNames = Set(substances.map { $0.nameUnwrapped.lowercased() })
        var namesThatShouldNotBeThere = [
            "2C-T-X",
            "2C-X",
            "25X-Nbome",
            "Amphetamine (Disambiguation)",
            "Antihistamine",
            "Antipsychotic",
            "Cannabinoid",
            "Datura (Botany)",
            "Deliriant",
            "Depressant",
            "Dox",
            "Harmala Alkaloid",
            "Hyoscyamus Niger (Botany)",
            "Hypnotic",
            "Iso-LSD",
            "List Of Prodrugs",
            "Mandragora Officinarum (Botany)",
            "Nbx",
            "Nootropic",
            "Phenethylamine (Compound)",
            "Piper Nigrum (Botany)",
            "RIMA",
            "Selective Serotonin Reuptake Inhibitor",
            "Serotonin",
            "Serotonin-Norepinephrine Reuptake Inhibitor",
            "Synthetic Cannabinoid",
            "Tabernanthe Iboga (Botany)",
            "Tryptamine (Compound)",
            "Cake",
            "Inhalants"
        ]
        namesThatShouldNotBeThere = namesThatShouldNotBeThere.map {$0.lowercased()}
        for subName in subNames {
            XCTAssertFalse(namesThatShouldNotBeThere.contains(subName), "\(subName) was parsed as a substance")
            XCTAssertFalse(subName.localizedCaseInsensitiveContains("experience"), "\(subName) contains the word experience")
        }
    }

    // swiftlint:disable cyclomatic_complexity
    func testCoreDataAssumptions() throws {
        let substances = try getAllSubstances()
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
        XCTAssertEqual(lsd.firstPsychoactiveNameUnwrapped, "Psychedelics")
        XCTAssertEqual(lsd.chemicalsUnwrapped.count, 1)
        XCTAssertEqual(lsd.chemicalsUnwrapped.first!.name, "Lysergamides")
        XCTAssertEqual(lsd.firstChemicalNameUnwrapped, "Lysergamides")
        XCTAssertEqual(lsd.crossToleranceChemicalsUnwrapped.count, 0)
        XCTAssertEqual(lsd.crossToleranceSubstancesUnwrapped.count, 0)
        XCTAssertEqual(lsd.crossTolerancePsychoactivesUnwrapped.count, 1)
        XCTAssertEqual(lsd.crossTolerancePsychoactivesUnwrapped.first!.name, "Psychedelics")
        // Check if interactions are supersets of what it says in the json file
        // This is because in the json the interactions are not always mutual
        // uncertain
        XCTAssertTrue(Set(lsd.uncertainSubstancesUnwrapped.map { $0.name }).isSuperset(of: ["Cannabis"]))
        XCTAssertTrue(Set(lsd.uncertainChemicalsUnwrapped.map { $0.name }).isSuperset(of: []))
        XCTAssertTrue(Set(lsd.uncertainPsychoactivesUnwrapped.map { $0.name }).isSuperset(of: ["Stimulants"]))
        XCTAssertTrue(Set(lsd.uncertainUnresolvedsUnwrapped.map { $0.name }).isSuperset(of: []))
        // unsafe
        XCTAssertTrue(Set(lsd.unsafeSubstancesUnwrapped.map { $0.name }).isSuperset(of: ["Tramadol"]))
        XCTAssertTrue(Set(lsd.unsafeChemicalsUnwrapped.map { $0.name }).isSuperset(of: []))
        XCTAssertTrue(Set(lsd.unsafePsychoactivesUnwrapped.map { $0.name }).isSuperset(of: ["Deliriants"]))
        XCTAssertTrue(Set(lsd.unsafeUnresolvedsUnwrapped.map { $0.name }).isSuperset(of: ["Tricyclic Antidepressants", "Ritonavir"]))
        // dangerous
        XCTAssertTrue(Set(lsd.dangerousSubstancesUnwrapped.map { $0.name }).isSuperset(of: []))
        XCTAssertTrue(Set(lsd.dangerousChemicalsUnwrapped.map { $0.name }).isSuperset(of: []))
        XCTAssertTrue(Set(lsd.dangerousPsychoactivesUnwrapped.map { $0.name }).isSuperset(of: []))
        XCTAssertTrue(Set(lsd.dangerousUnresolvedsUnwrapped.map { $0.name }).isSuperset(of: []))
    }
}
