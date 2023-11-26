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

    func test_shouldGetExpansionFrom32BitBlock() throws {
        let bit32: UInt32 = 0b0101_0101_0101_0101_0101_0101_0101_0101
        let sut = DES(key: 0)
        let ebits = sut.expansion(bit32)
        XCTAssertEqual(ebits, 0b101010_101010_101010_101010_101010_101010_101010_101010)
    }

    func test_should32BitPermutate() throws {
        let bit32: UInt32 = 0b1010_1010_1010_1010_1010_1010_1010_1010
        let sut = DES(key: 0)
        let permuted = sut.permutate(bit32)
        XCTAssertEqual(permuted, 0b0101_1001_1110_1010_0000_0111_1100_0101)
    }

    func test_shouldLoolkupS1Value() throws {
        let sixBit: UInt8 = 0b00100000 //row 2 column 0 -> 4
        let sut = DES(key: 0)
        let s1 = sut.sfunction(sixBit, sTable: DES.s1)
        XCTAssertEqual(s1, 0b00000100)
    }

    func test_shouldGet48BitKeyFrom64Bits() throws {
        let key64 = UInt64.random(in: 0...UInt64.max)
        let sut = DES(key: key64)
        let key48 = sut.genKey()
        print(key48)
        XCTAssertNotEqual(key48, 0)
    }

    func test_shouldPC2Value() throws {
        let bit56: UInt64 = 0b1010_1010_1010_1010_1010_1010_1010_1010_1010_1010_1010_1010_1010_1010
        let sut = DES(key: 0)
        let pc2 = sut.pc2Create(bit56)
        XCTAssertEqual(pc2, 0b011011_101010_110000_011010_101111_001110_011001_000010)
    }

    func test_shouldPC2FromTwo32Bits() throws {
        let bit32_L: UInt32 = 0b1010_1010_1010_1010_1010_1010_1010
        let bit32_R: UInt32 = 0b1010_1010_1010_1010_1010_1010_1010
        let sut = DES(key: 0)
        let pc2 = sut.pc2Create(bit32_L, bit32_R)
        XCTAssertEqual(pc2, 0b011011_101010_110000_011010_101111_001110_011001_000010)
    }

    func test_shouldShiftAndCombineKVals() throws {
        let badKey: UInt64 = 0b10 // this is bit 63 -> in right table max value
        // when shifted goes to farthest bit on right
        let sut = DES(key: badKey)
        let combined = sut.shiftAndCombineKVals(sut.pc1_left, sut.pc1_right)
        XCTAssertEqual(combined, 0b1)
    }

    func test_shouldGenerateAllPC2s() throws {
        let badKey: UInt64 = 0b10
        let sut = DES(key: badKey)
        let pc2Choices = sut.generatePC2List()
        XCTAssertEqual(pc2Choices.count, 16)
    }

    func test_canPerformInitialSetup() throws {
        let badKey: UInt64 = 0b10
        let sut = DES(key: badKey)
        let firstKey = sut.genKey()
        let pc2 = sut.pc2Create(firstKey)
        XCTAssertEqual(pc2, 1)
    }

    func test_shouldXORExpandedAndPC2() throws {
        let message = "Message!"
        let badKey: UInt64 = 0b10
        let sut = DES(key: badKey)
        
        // Key stuff
        var pc_l = sut.pc1_left
        var pc_r = sut.pc1_right

        pc_l = singleLeftshift(pc_l)!
        pc_r = singleLeftshift(pc_r)!
        var combo = sut.combineKVals(UInt64(pc_l), UInt64(pc_r))
        combo = sut.pc2Create(combo)

        // Message stuff
        sut.setBlock(message.uint64!)
        let rs_1 = sut.initialPermutation()
        let split1 = rs_1?.split()
        let exp1 = sut.expansion(split1!.1)

        // Combine them
        var new = combo ^ exp1

        print(new)
    }
}
