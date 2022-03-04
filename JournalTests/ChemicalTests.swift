import XCTest
@testable import Journal
import CoreData

class ChemicalTests: XCTestCase {

    override func setUp() {
        super.setUp()
        PersistenceController.preview.addInitialSubstances()
    }

    override func tearDown() {
        PersistenceController.preview.deleteAllSubstances()
        super.tearDown()
    }

    // swiftlint:disable function_body_length
    func testHasMost() throws {
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
}
