import XCTest
@testable import Journal
import CoreData

// swiftlint:disable type_body_length
class SubstanceTests: XCTestCase {

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
        XCTAssertGreaterThanOrEqual(substances.count, 354)
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

    // swiftlint:disable function_body_length
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
            "MAOI",
            "Opioids",
            "Benzodiazepines"
        ]
        namesThatShouldNotBeThere = namesThatShouldNotBeThere.map {$0.lowercased()}
        for subName in subNames {
            XCTAssertFalse(namesThatShouldNotBeThere.contains(subName), "\(subName) was parsed as a substance")
            XCTAssertFalse(subName.localizedCaseInsensitiveContains("experience"),
                           "\(subName) contains the word experience")
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
        XCTAssertTrue(Set(lsd.uncertainSubstancesToShow.map { $0.name }).contains("Cannabis"))
        XCTAssertTrue(Set(lsd.uncertainPsychoactivesToShow.map { $0.name }).contains("Stimulants"))
        XCTAssertTrue(Set(lsd.unsafeSubstancesToShow.map { $0.name }).contains("Tramadol"))
        XCTAssertTrue(Set(lsd.unsafePsychoactivesToShow.map { $0.name }).contains("Deliriants"))
        XCTAssertTrue(Set(lsd.unsafeUnresolvedsToShow.map { $0.name }).contains("Tricyclic Antidepressants"))
        XCTAssertTrue(Set(lsd.unsafeUnresolvedsToShow.map { $0.name }).contains("Ritonavir"))
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
        let uncertainSubstanceNames = Set(mdma.uncertainSubstancesToShow.map { $0.name })
        XCTAssertTrue(uncertainSubstanceNames.contains("5-MeO-DALT"))
        XCTAssertTrue(uncertainSubstanceNames.contains("5-MeO-DMT"))
        XCTAssertTrue(uncertainSubstanceNames.contains("5-MeO-DiPT"))
        XCTAssertTrue(uncertainSubstanceNames.contains("5-MeO-EiPT"))
        XCTAssertTrue(uncertainSubstanceNames.contains("5-MeO-MiPT"))
        XCTAssertTrue(uncertainSubstanceNames.contains("5-MeO-aMT"))
        XCTAssertTrue(uncertainSubstanceNames.contains("Cocaine"))
        XCTAssertTrue(uncertainSubstanceNames.contains("DOC"))
        XCTAssertTrue(uncertainSubstanceNames.contains("DOB"))
        XCTAssertTrue(uncertainSubstanceNames.contains("DOM"))
        XCTAssertTrue(uncertainSubstanceNames.contains("DOI"))
        XCTAssertTrue(uncertainSubstanceNames.contains("GHB"))
        XCTAssertTrue(uncertainSubstanceNames.contains("GBL"))
        XCTAssertTrue(uncertainSubstanceNames.contains("Methoxetamine"))
        XCTAssertTrue(uncertainSubstanceNames.contains("AMT"))
        let uncertainChemicalNames = Set(mdma.uncertainChemicalsToShow.map { $0.name })
        XCTAssertTrue(uncertainChemicalNames.contains("Alcohols"))
        let unsafeSubstanceNames = Set(mdma.unsafeSubstancesToShow.map { $0.name })
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
        XCTAssertTrue(Set(mdma.unsafeUnresolvedsToShow.map { $0.name }).contains("Serotonin"))
        let dangerousSubstanceNames = Set(mdma.dangerousSubstancesToShow.map { $0.name })
        XCTAssertTrue(dangerousSubstanceNames.contains("Tramadol"))
        XCTAssertTrue(dangerousSubstanceNames.contains("Dextromethorphan"))
        XCTAssertTrue(Set(mdma.dangerousUnresolvedsToShow.map { $0.name }).contains("MAOI"))
    }

    func testCocaine() throws {
        let fetchRequest = Substance.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", "Cocaine")
        let substances = try PersistenceController.preview.viewContext.fetch(fetchRequest)
        XCTAssertEqual(substances.count, 1)
        let cocaine = substances.first!
        XCTAssertEqual(cocaine.psychoactivesUnwrapped.count, 1)
        XCTAssertEqual(cocaine.psychoactivesUnwrapped.first!.name, "Stimulants")
        XCTAssertEqual(cocaine.firstPsychoactiveNameUnwrapped, "Stimulants")
        XCTAssertEqual(cocaine.chemicalsUnwrapped.count, 1)
        XCTAssertEqual(cocaine.chemicalsUnwrapped.first!.name, "Substituted Tropanes")
        XCTAssertEqual(cocaine.firstChemicalNameUnwrapped, "Substituted Tropanes")
        XCTAssertEqual(cocaine.crossToleranceChemicalsUnwrapped.count, 0)
        XCTAssertEqual(cocaine.crossToleranceSubstancesUnwrapped.count, 0)
        XCTAssertEqual(cocaine.crossTolerancePsychoactivesUnwrapped.count, 1)
        XCTAssertEqual(cocaine.crossTolerancePsychoactivesUnwrapped.first!.name, "Stimulants")
        let dangerousPsychoactiveNames = Set(cocaine.dangerousPsychoactivesToShow.map { $0.name })
        XCTAssertTrue(dangerousPsychoactiveNames.contains("Opioids"))
        let dangerousSubstanceNames = Set(cocaine.dangerousSubstancesToShow.map { $0.name })
        XCTAssertTrue(dangerousSubstanceNames.contains("AMT"))
        let dangerousUnresolvedNames = Set(cocaine.dangerousUnresolvedsToShow.map { $0.name })
        XCTAssertTrue(dangerousUnresolvedNames.contains("MAOI"))
        let unsafeSubstanceNames = Set(cocaine.unsafeSubstancesToShow.map { $0.name })
        XCTAssertTrue(unsafeSubstanceNames.contains("25B-NBOMe"))
        XCTAssertTrue(unsafeSubstanceNames.contains("25C-NBOMe"))
        XCTAssertTrue(unsafeSubstanceNames.contains("25D-NBOMe"))
        XCTAssertTrue(unsafeSubstanceNames.contains("25H-NBOMe"))
        XCTAssertTrue(unsafeSubstanceNames.contains("25I-NBOMe"))
        XCTAssertTrue(unsafeSubstanceNames.contains("25N-NBOMe"))
        XCTAssertTrue(unsafeSubstanceNames.contains("PCP"))
        XCTAssertTrue(unsafeSubstanceNames.contains("2C-T-2"))
        XCTAssertTrue(unsafeSubstanceNames.contains("2C-T-7"))
        XCTAssertTrue(unsafeSubstanceNames.contains("DOB"))
        XCTAssertTrue(unsafeSubstanceNames.contains("DOM"))
        XCTAssertTrue(unsafeSubstanceNames.contains("DOI"))
        XCTAssertTrue(unsafeSubstanceNames.contains("Dextromethorphan"))
        XCTAssertTrue(unsafeSubstanceNames.contains("5-MeO-DALT"))
        XCTAssertTrue(unsafeSubstanceNames.contains("5-MeO-DMT"))
        XCTAssertTrue(unsafeSubstanceNames.contains("5-MeO-DiPT"))
        XCTAssertTrue(unsafeSubstanceNames.contains("5-MeO-EiPT"))
        XCTAssertTrue(unsafeSubstanceNames.contains("5-MeO-MiPT"))
        XCTAssertTrue(unsafeSubstanceNames.contains("5-MeO-aMT"))
        let unsafeChemicalNames = Set(cocaine.unsafeChemicalsToShow.map { $0.name })
        XCTAssertTrue(unsafeChemicalNames.contains("Alcohols"))
        let uncertainSubstanceNames = Set(cocaine.uncertainSubstancesToShow.map { $0.name })
        XCTAssertTrue(uncertainSubstanceNames.contains("Psilocybin Mushrooms"))
        XCTAssertTrue(uncertainSubstanceNames.contains("LSD"))
        XCTAssertTrue(uncertainSubstanceNames.contains("DMT"))
        XCTAssertTrue(uncertainSubstanceNames.contains("Mescaline"))
        XCTAssertTrue(uncertainSubstanceNames.contains("2C-B"))
        XCTAssertTrue(uncertainSubstanceNames.contains("2C-C"))
        XCTAssertTrue(uncertainSubstanceNames.contains("2C-D"))
        XCTAssertTrue(uncertainSubstanceNames.contains("2C-E"))
        XCTAssertTrue(uncertainSubstanceNames.contains("2C-H"))
        XCTAssertTrue(uncertainSubstanceNames.contains("2C-I"))
        XCTAssertTrue(uncertainSubstanceNames.contains("2C-P"))
        XCTAssertTrue(uncertainSubstanceNames.contains("2C-T"))
        XCTAssertTrue(uncertainSubstanceNames.contains("Cannabis"))
        XCTAssertTrue(uncertainSubstanceNames.contains("Ketamine"))
        XCTAssertTrue(uncertainSubstanceNames.contains("Methoxetamine"))
        XCTAssertTrue(uncertainSubstanceNames.contains("MDMA"))
        XCTAssertTrue(uncertainSubstanceNames.contains("Caffeine"))
        XCTAssertTrue(uncertainSubstanceNames.contains("GHB"))
        XCTAssertTrue(uncertainSubstanceNames.contains("GBL"))
        let uncertainChemicalNames = Set(cocaine.uncertainChemicalsToShow.map { $0.name })
        XCTAssertTrue(uncertainChemicalNames.contains("Substituted Amphetamines"))
    }

    func testHeroin() throws {
        let fetchRequest = Substance.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", "Heroin")
        let substances = try PersistenceController.preview.viewContext.fetch(fetchRequest)
        XCTAssertEqual(substances.count, 1)
        let heroin = substances.first!
        XCTAssertEqual(heroin.psychoactivesUnwrapped.count, 1)
        XCTAssertEqual(heroin.psychoactivesUnwrapped.first!.name, "Opioids")
        XCTAssertEqual(heroin.firstPsychoactiveNameUnwrapped, "Opioids")
        XCTAssertEqual(heroin.chemicalsUnwrapped.count, 1)
        XCTAssertEqual(heroin.chemicalsUnwrapped.first!.name, "Substituted Morphinans")
        XCTAssertEqual(heroin.firstChemicalNameUnwrapped, "Substituted Morphinans")
        XCTAssertEqual(heroin.crossToleranceChemicalsUnwrapped.count, 0)
        XCTAssertEqual(heroin.crossToleranceSubstancesUnwrapped.count, 0)
        XCTAssertEqual(heroin.crossTolerancePsychoactivesUnwrapped.count, 1)
        XCTAssertEqual(heroin.crossTolerancePsychoactivesUnwrapped.first!.name, "Opioids")
        let dangerousChemicalNames = Set(heroin.dangerousChemicalsToShow.map { $0.name })
        XCTAssertTrue(dangerousChemicalNames.contains("Alcohols"))
        XCTAssertTrue(dangerousChemicalNames.contains("Benzodiazepines"))
        let dangerousSubstanceNames = Set(heroin.dangerousSubstancesToShow.map { $0.name })
        XCTAssertTrue(dangerousSubstanceNames.contains("Cocaine"))
        XCTAssertTrue(dangerousSubstanceNames.contains("Dextromethorphan"))
        XCTAssertTrue(dangerousSubstanceNames.contains("Ketamine"))
        XCTAssertTrue(dangerousSubstanceNames.contains("Methoxetamine"))
        XCTAssertTrue(dangerousSubstanceNames.contains("Tramadol"))
        XCTAssertTrue(dangerousSubstanceNames.contains("GHB"))
        XCTAssertTrue(dangerousSubstanceNames.contains("GBL"))
        let dangerousUnresolvedNames = Set(heroin.dangerousUnresolvedsToShow.map { $0.name })
        XCTAssertTrue(dangerousUnresolvedNames.contains("Grapefruit"))
        let uncertainSubstanceNames = Set(heroin.uncertainSubstancesToShow.map { $0.name })
        XCTAssertTrue(uncertainSubstanceNames.contains("Nitrous"))
        XCTAssertTrue(uncertainSubstanceNames.contains("PCP"))
        let uncertainChemicalNames = Set(heroin.uncertainChemicalsToShow.map { $0.name })
        XCTAssertTrue(uncertainChemicalNames.contains("Substituted Amphetamines"))
        let uncertainUnresolvedNames = Set(heroin.uncertainUnresolvedsToShow.map { $0.name })
        XCTAssertTrue(uncertainUnresolvedNames.contains("MAOI"))
    }
}
