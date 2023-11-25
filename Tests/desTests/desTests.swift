import XCTest
@testable import des

final class desTests: XCTestCase {
    func test_shouldLeftCircShift() throws {
        var bits: UInt8 = 0b10000001
        XCTAssertEqual(bits <<< 1, 0b00000011)
        bits = 0b10000001
        print(bits)
        XCTAssertEqual(bits >>> 1, 0b11000000)
        print(bits)
    }
}
