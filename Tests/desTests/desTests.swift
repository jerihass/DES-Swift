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
        var pc1 = sut.pc1Left
        XCTAssertEqual(pc1, 0b0000111100001111000011110000)

        pc1 = sut.pc1Right
        XCTAssertEqual(pc1, 0b0000111100001111000011111111)

        let testKey = "TestKeys"
        sut = DES(key: testKey.uint64!)
        pc1 = sut.pc1Left
        pc1 = sut.pc1Right
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
        sut.setMessageBlock(binaryMessage)
        let ip = try XCTUnwrap(sut.initialPermutation(of: binaryMessage))
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

    func test_shouldMake32From48WithSVals() throws {
        let bit48: UInt64 = 0b000000_000001_000011_000100_000101_000110_000111_001000
        let sut = DES(key: 0)
        let s1 = sut.sfunction(0b000000, sTable: DES.s1) //0,0
        let s2 = sut.sfunction(0b000001, sTable: DES.s2) //1,0
        let s3 = sut.sfunction(0b000011, sTable: DES.s3) //1,1
        let s4 = sut.sfunction(0b000100, sTable: DES.s4) //0,2
        let s5 = sut.sfunction(0b000101, sTable: DES.s5) //1,2
        let s6 = sut.sfunction(0b000110, sTable: DES.s6) //0,3
        let s7 = sut.sfunction(0b000111, sTable: DES.s7) //1,3
        let s8 = sut.sfunction(0b001000, sTable: DES.s8) //0,4

        XCTAssertEqual(s1, 14)
        XCTAssertEqual(s2, 3)
        XCTAssertEqual(s3, 7)
        XCTAssertEqual(s4, 14)
        XCTAssertEqual(s5, 2)
        XCTAssertEqual(s6, 15)
        XCTAssertEqual(s7, 7)
        XCTAssertEqual(s8, 6)
        var sCombo: UInt32 = (UInt32(s1!) << 28) | (UInt32(s2!) << 24) | (UInt32(s3!) << 20) | (UInt32(s4!) << 16)
        sCombo = sCombo | (UInt32(s5!) << 12) | (UInt32(s6!) << 8) | (UInt32(s7!) << 4) | (UInt32(s8!) << 0)
        let sOut = sut.sBox(bit48)

        XCTAssertEqual(sOut, sCombo)
    }

    func test_shouldConvert48_64BitsInto8SectionsOf6() throws {
        let bit48: UInt64 = 0b000000_000001_000011_000100_000101_000110_000111_001000
        let sut = DES(key: 0)
        let sections = sut.break48Into6Bits(bit48)
        XCTAssertEqual(sections, [0, 1, 3, 4, 5, 6, 7, 8])
    }

    func test_shouldGet48BitKeyFrom64Bits() throws {
        let key64 = UInt64.random(in: 0...UInt64.max)
        let sut = DES(key: key64)
        let key48 = sut.genKey()
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
        let combined = sut.shiftAndCombineKVals(sut.pc1Left, sut.pc1Right)
        XCTAssertEqual(combined, 0b1)
    }

    func test_shouldGenerateAllPC2s() throws {
        let badKey: UInt64 = 0b10
        let sut = DES(key: badKey)
        let pc2Choices = sut.generatePC2List()
        XCTAssertEqual(pc2Choices.count, 16)
//        XCTAssertEqual(pc2Choices, )
    }

    func test_shouldDoSingleRoundMutation() throws {
        let badKey: UInt64 = 0b10
        let message: UInt64 = "Message!".uint64!
        let sut = DES(key: badKey)
        sut.setMessageBlock(message)
        let pc1 = sut.pc2List.first!
        let encrypted = sut.cryptedBlock(input: message, with: pc1)
        let val = combine32Bits(encrypted.0, encrypted.1)
        XCTAssertNotEqual(val, message)
    }

    func test_shouldEncryptAndDecrypt() throws {
        let aKey: UInt64 = UInt64.random(in: 0...UInt64.max)
        let message: UInt64 = "Message!".uint64!
        let sut = DES(key: aKey)
        sut.setMessageBlock(message)
        let encrypted = sut.encryptBlock()
        print("Encrypted: " + String(encrypted, radix: 16))
        sut.setCyperBlock(encrypted)
        let decrypted = sut.decryptBlock()
        XCTAssertNotEqual(encrypted, 0)
        XCTAssertNotEqual(decrypted, 0)
        XCTAssertEqual(message, decrypted)
    }

    func test_shouldDoInversePerm() throws {
        // all even bits from left are 1
        let bit64: UInt64 = 0x5555555555555555
        let sut = DES(key: 0)
        let ip = sut.inversePermutation(bit64)
        XCTAssertEqual(ip, 0b11111111_00000000_11111111_00000000_11111111_00000000_11111111_00000000)
    }

    func test_shouldXORExpandedAndPC2() throws {
        let message = "Message!"
        let badKey: UInt64 = 0b10
        let sut = DES(key: badKey)
        
        // Key stuff
        var pc_l = sut.pc1Left
        var pc_r = sut.pc1Right

        pc_l = singleLeftshift(pc_l)!
        pc_r = singleLeftshift(pc_r)!
        var combo = sut.combineKVals(UInt64(pc_l), UInt64(pc_r))
        combo = sut.pc2Create(combo)

        // Message stuff
        sut.setMessageBlock(message.uint64!)
        let rs_1 = sut.initialPermutation(of: message.uint64!)
        let split1 = rs_1?.split()
        let exp1 = sut.expansion(split1!.1)

        // Combine them
        let _ = combo ^ exp1
    }

    func test_shouldSwap64Bit() throws {
        let bit64: UInt64 = 0b11111111_11111111_11111111_11111111_00000000_00000000_00000000_00000000
        let swapped = swap64(bit64)
        XCTAssertEqual(swapped, 0b00000000_00000000_00000000_00000000_11111111_11111111_11111111_11111111)
    }

    func test_shouldCombine32Bits() throws {
        let left: UInt32 = 0b11111111_11111111_11111111_11111111
        let right: UInt32 = 0b00000000_00000000_00000000_00000000
        let combo = combine32Bits(left, right)
        XCTAssertEqual(combo, 0b11111111_11111111_11111111_11111111_00000000_00000000_00000000_00000000)
    }
}
