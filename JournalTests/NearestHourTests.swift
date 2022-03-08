import XCTest
@testable import Journal

class NearestHourTests: XCTestCase {

    func testRoundUp() throws {
        var components = DateComponents()
        components.year = 2022
        components.month = 2
        components.day = 19
        components.hour = 5
        components.minute = 26
        components.second = 5
        let calendar = Calendar.current
        let time = calendar.date(from: components)!
        let nearest = time.nearestFullHourInTheFuture()!
        XCTAssertEqual(calendar.component(.year, from: nearest), 2022)
        XCTAssertEqual(calendar.component(.month, from: nearest), 2)
        XCTAssertEqual(calendar.component(.day, from: nearest), 19)
        XCTAssertEqual(calendar.component(.hour, from: nearest), 6)
        XCTAssertEqual(calendar.component(.minute, from: nearest), 0)
        XCTAssertEqual(calendar.component(.second, from: nearest), 0)
    }

    func testAlreadyFull() throws {
        var components = DateComponents()
        components.year = 2022
        components.month = 2
        components.day = 19
        components.hour = 5
        components.minute = 0
        components.second = 0
        let calendar = Calendar.current
        let time = calendar.date(from: components)!
        let nearest = time.nearestFullHourInTheFuture()!
        XCTAssertEqual(calendar.component(.year, from: nearest), 2022)
        XCTAssertEqual(calendar.component(.month, from: nearest), 2)
        XCTAssertEqual(calendar.component(.day, from: nearest), 19)
        XCTAssertEqual(calendar.component(.hour, from: nearest), 5)
        XCTAssertEqual(calendar.component(.minute, from: nearest), 0)
        XCTAssertEqual(calendar.component(.second, from: nearest), 0)
    }

    func testOverMidnight() throws {
        var components = DateComponents()
        components.year = 2022
        components.month = 2
        components.day = 19
        components.hour = 23
        components.minute = 3
        components.second = 0
        let calendar = Calendar.current
        let time = calendar.date(from: components)!
        let nearest = time.nearestFullHourInTheFuture()!
        XCTAssertEqual(calendar.component(.year, from: nearest), 2022)
        XCTAssertEqual(calendar.component(.month, from: nearest), 2)
        XCTAssertEqual(calendar.component(.day, from: nearest), 20)
        XCTAssertEqual(calendar.component(.hour, from: nearest), 0)
        XCTAssertEqual(calendar.component(.minute, from: nearest), 0)
        XCTAssertEqual(calendar.component(.second, from: nearest), 0)
    }
}
