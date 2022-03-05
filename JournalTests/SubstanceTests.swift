import XCTest
@testable import Journal
import CoreData

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
        XCTAssertGreaterThanOrEqual(substances.count, 356)
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
            "Inhalants",
            "MAOI"
        ]
        namesThatShouldNotBeThere = namesThatShouldNotBeThere.map {$0.lowercased()}
        for subName in subNames {
            XCTAssertFalse(namesThatShouldNotBeThere.contains(subName), "\(subName) was parsed as a substance")
            XCTAssertFalse(subName.localizedCaseInsensitiveContains("experience"),
                           "\(subName) contains the word experience")
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
        XCTAssertTrue(Set(lsd.uncertainSubstancesUnwrapped.map { $0.name }).contains("Cannabis"))
        XCTAssertTrue(Set(lsd.uncertainPsychoactivesUnwrapped.map { $0.name }).contains("Stimulants"))
        XCTAssertTrue(Set(lsd.unsafeSubstancesUnwrapped.map { $0.name }).contains("Tramadol"))
        XCTAssertTrue(Set(lsd.unsafePsychoactivesUnwrapped.map { $0.name }).contains("Deliriants"))
        XCTAssertTrue(Set(lsd.unsafeUnresolvedsUnwrapped.map { $0.name }).contains("Tricyclic Antidepressants"))
        XCTAssertTrue(Set(lsd.unsafeUnresolvedsUnwrapped.map { $0.name }).contains("Ritonavir"))
    }

    // swiftlint:disable function_body_length
    func testMDMA() throws {
        let fetchRequest = Substance.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", "MDMA")
        let substances = try PersistenceController.preview.viewContext.fetch(fetchRequest)
        XCTAssertEqual(substances.count, 1)
        let mdma = substances.first!
        XCTAssertEqual(mdma.psychoactivesUnwrapped.count, 1)
        XCTAssertEqual(mdma.psychoactivesUnwrapped.first!.name, "Miscellaneous")
        XCTAssertEqual(mdma.firstPsychoactiveNameUnwrapped, "Miscellaneous")
        XCTAssertEqual(mdma.chemicalsUnwrapped.count, 1)
        XCTAssertEqual(mdma.chemicalsUnwrapped.first!.name, "Miscellaneous")
        XCTAssertEqual(mdma.firstChemicalNameUnwrapped, "Miscellaneous")
        XCTAssertEqual(mdma.crossToleranceChemicalsUnwrapped.count, 0)
        XCTAssertEqual(mdma.crossToleranceSubstancesUnwrapped.count, 0)
        XCTAssertEqual(mdma.crossTolerancePsychoactivesUnwrapped.count, 1)
        XCTAssertEqual(mdma.crossTolerancePsychoactivesUnwrapped.first!.name, "Stimulants")
        let uncertainSubstanceNames = Set(mdma.uncertainSubstancesUnwrapped.map { $0.name })
        XCTAssertTrue(uncertainSubstanceNames.contains("5-MeO-DALT"))
        XCTAssertTrue(uncertainSubstanceNames.contains("5-MeO-DMT"))
        XCTAssertTrue(uncertainSubstanceNames.contains("5-MeO-DiPT"))
        XCTAssertTrue(uncertainSubstanceNames.contains("5-MeO-EiPT"))
        XCTAssertTrue(uncertainSubstanceNames.contains("5-MeO-MiPT"))
        XCTAssertTrue(uncertainSubstanceNames.contains("5-MeO-aMT"))
        XCTAssertTrue(uncertainSubstanceNames.contains("Alcohol"))
        XCTAssertTrue(uncertainSubstanceNames.contains("Cocaine"))
        XCTAssertTrue(uncertainSubstanceNames.contains("DOC"))
        XCTAssertTrue(uncertainSubstanceNames.contains("DOB"))
        XCTAssertTrue(uncertainSubstanceNames.contains("DOM"))
        XCTAssertTrue(uncertainSubstanceNames.contains("DOI"))
        XCTAssertTrue(uncertainSubstanceNames.contains("GHB"))
        XCTAssertTrue(uncertainSubstanceNames.contains("GBL"))
        XCTAssertTrue(uncertainSubstanceNames.contains("Methoxetamine"))
        XCTAssertTrue(uncertainSubstanceNames.contains("AMT"))
        let unsafeSubstanceNames = Set(mdma.unsafeSubstancesUnwrapped.map { $0.name })
        XCTAssertTrue(unsafeSubstanceNames.contains("25B-NBOMe"))
        XCTAssertTrue(unsafeSubstanceNames.contains("25C-NBOMe"))
        XCTAssertTrue(unsafeSubstanceNames.contains("25D-NBOMe"))
        XCTAssertTrue(unsafeSubstanceNames.contains("25H-NBOMe"))
        XCTAssertTrue(unsafeSubstanceNames.contains("25I-NBOMe"))
        XCTAssertTrue(unsafeSubstanceNames.contains("25N-NBOMe"))
        XCTAssertTrue(unsafeSubstanceNames.contains("PCP"))
        XCTAssertTrue(unsafeSubstanceNames.contains("2C-T-2"))
        XCTAssertTrue(unsafeSubstanceNames.contains("2C-T-7"))
        XCTAssertTrue(unsafeSubstanceNames.contains("5-Hydroxytryptophan"))
        XCTAssertTrue(Set(mdma.unsafeUnresolvedsUnwrapped.map { $0.name }).contains("Serotonin"))
        let dangerousSubstanceNames = Set(mdma.dangerousSubstancesUnwrapped.map { $0.name })
        XCTAssertTrue(dangerousSubstanceNames.contains("Tramadol"))
        XCTAssertTrue(dangerousSubstanceNames.contains("Dextromethorphan"))
        XCTAssertTrue(Set(mdma.dangerousUnresolvedsUnwrapped.map { $0.name }).contains("MAOI"))
    }
}
