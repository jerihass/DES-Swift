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

    func test_shouldLeftLimitedCircShiftOne() throws {
        var bits: UInt32 = 0b0000100000000000_0000000000000001
        bits = singleLeftshift(bits)!
        XCTAssertEqual(bits, 0b0000000000000000_0000000000000011)
    }

    func test_shouldLeftLimitedCircShiftTwo() throws {
        var bits: UInt32 = 0b0000110000000000_0000000000000001
        bits = doubleLeftshift(bits)!
        XCTAssertEqual(bits, 0b0000000000000000_0000000000000111)
    }

    func test_shouldSplit64Bit() throws {
        let bits: UInt64 = 0b1111111111111111111111111111111010000000000000000000000000000001
        let split = bits.split()
        XCTAssertEqual(split.0, 0b11111111111111111111111111111110)
        XCTAssertEqual(split.1, 0b10000000000000000000000000000001)
    }

    func test_shouldUseLookupTable() throws {
        let table = DES.ip
        let value = table.lookup(0) as? UInt8
        XCTAssertEqual(value, UInt8(58))
    }

    func test_shouldGetBitAtPosition() throws {
        let value: UInt64 = 0b1000000000000000000000000000000000000000000000000000000000000001
        var bit = value.getBit(1)
        XCTAssertEqual(bit, 1)
        bit = value.getBit(33)
        XCTAssertEqual(bit, 0)
        bit = value.getBit(64)
        XCTAssertEqual(bit, 1)
    }

    func test_shouldPC1OfKey() throws {
        var sut = DES(key: testBits)
        var pc1 = sut.pc1_left
        XCTAssertEqual(pc1, 0b0000111100001111000011110000)

        pc1 = sut.pc1_right
        XCTAssertEqual(pc1, 0b0000111100001111000011111111)

        let testKey = "TestKeys"
        sut = DES(key: testKey.uint64!)
        pc1 = sut.pc1_left
        print(pc1)
        pc1 = sut.pc1_right
        print(pc1)
    }

    func test_shouldConvert64BitStringToUInt64() throws {
        let testString = "TestKeys"
        let binaryString = try XCTUnwrap(testString.uint64)
        XCTAssertEqual(binaryString, 0b0111001101111001011001010100101101110100011100110110010101010100)
        XCTAssertEqual(String(binaryString), testString)
    }

    func test_shouldEncypherWithInitialPermuationAndProvideProperSplits() throws {
        let binaryMessage: UInt64 = 0b0101_0101_0101_0101_0101_0101_0101_0101_0101_0101_0101_0101_0101_0101_0101_0101
        XCTAssertEqual(binaryMessage.getBit(58), 1)
        let key = "!GoodKey"
        let binaryKey = try XCTUnwrap(key.uint64)

        let sut = DES(key: binaryKey)
        sut.setBlock(binaryMessage)
        let ip = try XCTUnwrap(sut.initialPermutation())
        XCTAssertEqual(ip, 0b1111_1111_1111_1111_1111_1111_1111_1111_0000_0000_0000_0000_0000_0000_0000_0000)

        let split = ip.split()
        XCTAssertEqual(split.0, 0b1111_1111_1111_1111_1111_1111_1111_1111)
        XCTAssertEqual(split.1, 0b0000_0000_0000_0000_0000_0000_0000_0000)
    }
}
