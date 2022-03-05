import XCTest
@testable import Journal

class RegexTests: XCTestCase {

    func testDOx() throws {
        let regex = try "DOx".getRegexWithxAsWildcard()
        XCTAssertTrue(regex.isMatch(with: "DOB"))
        XCTAssertTrue(regex.isMatch(with: "DOBAX"))
        XCTAssertFalse(regex.isMatch(with: "ABDOB"))
    }

    func testMeo() throws {
        let regex = try "5-MeO-xXT".getRegexWithxAsWildcard()
        XCTAssertTrue(regex.isMatch(with: "5-MeO-abT"))
        XCTAssertTrue(regex.isMatch(with: "5-MeO-abCdeT"))
        XCTAssertTrue(regex.isMatch(with: "5-MeO-aT"))
        XCTAssertFalse(regex.isMatch(with: "ab5-MeO-abT"))
    }

    func testDex() throws {
        let regex = try "Dextromorphan".getRegexWithxAsWildcard()
        XCTAssertTrue(regex.isMatch(with: "Dextromorphan"))
    }

    func testSame() throws {
        let regex = try "Same".getRegexWithxAsWildcard()
        XCTAssertTrue(regex.isMatch(with: "Same"))
        XCTAssertFalse(regex.isMatch(with: "abcSamedef"))
        XCTAssertFalse(regex.isMatch(with: "Same012"))
        XCTAssertFalse(regex.isMatch(with: "01Same"))
    }

    func testSpaces() throws {
        let regex = try "Same substance with Spaces".getRegexWithxAsWildcard()
        XCTAssertTrue(regex.isMatch(with: "Same substance with Spaces"))
        XCTAssertFalse(regex.isMatch(with: "Samesubstancewith Spaces"))
    }

    func testSpacesWithX() throws {
        let regex = try "Same substancxwith Spaces".getRegexWithxAsWildcard()
        XCTAssertTrue(regex.isMatch(with: "Same substanc random here with Spaces"))
        XCTAssertFalse(regex.isMatch(with: "Other substancxwith Spaces"))
    }
}
