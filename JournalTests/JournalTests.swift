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

    func testHasEnoughSubstances() throws {
        let substances = try getAllSubstances()
        XCTAssertGreaterThan(substances.count, 388)
    }

    private func getAllSubstances() throws -> [Substance] {
        let fetchRequest = Substance.fetchRequest()
        return try PersistenceController.preview.viewContext.fetch(fetchRequest)
    }

    func testHasPsychoactives() throws {
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

    // swiftlint:disable function_body_length
    func testHasChemicals() throws {
        let chemicals = try getAllChemicals()
        let names = Set(chemicals.map { $0.nameUnwrapped })
        XCTAssertTrue(names.contains("Arylcyclohexylamines"))
        XCTAssertTrue(names.contains("Substituted Amphetamines"))
        XCTAssertTrue(names.contains("Substituted Tryptamines"))
        XCTAssertTrue(names.contains("Phenisobutylamines"))
        XCTAssertTrue(names.contains("Indazolecarboxamides"))
        XCTAssertTrue(names.contains("Substituted Phenidates"))
        XCTAssertTrue(names.contains("Substituted Benzofurans"))
        XCTAssertTrue(names.contains("Indolecarboxylates"))
        XCTAssertTrue(names.contains("Indazolecarboxamides"))
        XCTAssertTrue(names.contains("Lysergamides"))
        XCTAssertTrue(names.contains("Anilidopiperidines"))
        XCTAssertTrue(names.contains("Alcohols"))
        XCTAssertTrue(names.contains("Substituted Phenethylamines"))
        XCTAssertTrue(names.contains("Choline Derivatives"))
        XCTAssertTrue(names.contains("Benzodiazepines"))
        XCTAssertTrue(names.contains("Adamantanes"))
        XCTAssertTrue(names.contains("Racetams"))
        XCTAssertTrue(names.contains("Benzhydryls"))
        XCTAssertTrue(names.contains("Substituted Tropanes"))
        XCTAssertTrue(names.contains("Butyric Acids"))
        XCTAssertTrue(names.contains("Indazoles"))
        XCTAssertTrue(names.contains("Substituted Morphinans"))
        XCTAssertTrue(names.contains("Xanthines"))
        XCTAssertTrue(names.contains("Cannabinoids"))
        XCTAssertTrue(names.contains("Carbamates"))
        XCTAssertTrue(names.contains("Ammonium Salts"))
        XCTAssertTrue(names.contains("Imidazolines"))
        XCTAssertTrue(names.contains("Nitrogenous Organic Acids"))
        XCTAssertTrue(names.contains("Thienodiazepines"))
        XCTAssertTrue(names.contains("Substituted Piperidines"))
        XCTAssertTrue(names.contains("Phenylpropylamines"))
        XCTAssertTrue(names.contains("Ethanolamines"))
        XCTAssertTrue(names.contains("Diarylethylamines"))
        XCTAssertTrue(names.contains("Benzoxazines"))
        XCTAssertTrue(names.contains("Amphetamines"))
        XCTAssertTrue(names.contains("Substituted Cathinones"))
        XCTAssertTrue(names.contains("Gabapentinoids"))
        XCTAssertTrue(names.contains("Lactones"))
        XCTAssertTrue(names.contains("Khat#1#s"))
        XCTAssertTrue(names.contains("Inorganic Molecules"))
        XCTAssertTrue(names.contains("Naphthoylindoles"))
        XCTAssertTrue(names.contains("Indole Alkaloids"))
        XCTAssertTrue(names.contains("Substituted Piperazines"))
        XCTAssertTrue(names.contains("Aminoindanes"))
        XCTAssertTrue(names.contains("Quinazolinones"))
        XCTAssertTrue(names.contains("Diphenylpropylamines"))
        XCTAssertTrue(names.contains("Peptides"))
        XCTAssertTrue(names.contains("GABAs"))
        XCTAssertTrue(names.contains("Phenothiazines"))
        XCTAssertTrue(names.contains("Cycloalkylamines"))
    }

    private func getAllChemicals() throws -> [ChemicalClass] {
        let fetchRequest = ChemicalClass.fetchRequest()
        return try PersistenceController.preview.viewContext.fetch(fetchRequest)
    }

    func testPsychoactivesEndWithS() throws {
        let psychoactives = try getAllPsychoactives()
        let names = Set(psychoactives.map { $0.nameUnwrapped })
        for name in names {
            XCTAssertTrue(name.hasSuffix("s"), "\(name) doesn't have suffix s")
        }
    }

    func testNoPsychoactiveClassParsedAsSubstance() throws {
        let psychoactives = try getAllPsychoactives()
        var psyNames = Set(psychoactives.map { $0.nameUnwrapped })
        psyNames = psyNames.union([
            "Entheogen",
            "Antidepressants",
            "Gabapentinoids",
            "25x-NBOH",
            "Sedative",
            "Serotonergic psychedelic"
        ])
        let substances = try getAllSubstances()
        let subNames = Set(substances.map { $0.nameUnwrapped })
        for psyName in psyNames {
            XCTAssertFalse(subNames.contains(psyName), "\(psyName) was parsed as a substance")
        }
    }

    func testNoChemicalClassParsedAsSubstance() throws {
        let chemicals = try getAllChemicals()
        let cheNames = Set(chemicals.map { $0.nameUnwrapped })
        let substances = try getAllSubstances()
        let subNames = Set(substances.map { $0.nameUnwrapped })
        for cheName in cheNames {
            XCTAssertFalse(subNames.contains(cheName), "\(cheName) was parsed as a substance")
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
        XCTAssertEqual(lsd.chemicalsUnwrapped.count, 1)
        XCTAssertEqual(lsd.chemicalsUnwrapped.first!.name, "Lysergamides")
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
