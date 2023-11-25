import XCTest
@testable import des

final class desTests: XCTestCase {

    let testBits: UInt64 = 0b1111111111111111111111111111111100000000000000000000000000000000

    func test_shouldLeftCircShift() throws {
        var bits: UInt8 = 0b10000001
        XCTAssertEqual(bits <<< 1, 0b00000011)
        bits = 0b10000001
        XCTAssertEqual(bits >>> 1, 0b11000000)

        bits = 0b10000001
        XCTAssertEqual(bits.lcs(by: 1), 0b00000011)
        bits = 0b10000001
        XCTAssertEqual(bits.rcs(by: 1), 0b11000000)
    }

    func test_shouldSplit64Bit() throws {
        let bits: UInt64 = 0b1111111111111111111111111111111010000000000000000000000000000001
        let split = bits.split()
        XCTAssertEqual(split.0, 0b11111111111111111111111111111110)
        XCTAssertEqual(split.1, 0b10000000000000000000000000000001)
    }

    func test_shouldLookupSomething() throws {
        let table = DES.ip
        print(table)
        let value = table.lookup(0) as? UInt8
        XCTAssertEqual(value, UInt8(58))
    }

    func test_shouldGetBitAtPosition() throws {
        let value = testBits
        var bit = value.getBit(1)
        XCTAssertEqual(bit, 1)
        bit = value.getBit(33)
        XCTAssertEqual(bit, 0)
    }

    func test_shouldPC1OfKey() throws {
        let sut = DES(key: testBits)
        let pc1 = sut.pc1_left
        XCTAssertEqual(pc1, 0b0000111100001111000011110000)
        print(pc1)
    }
}
