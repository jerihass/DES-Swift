//
//  Created by Jericho Hasselbush on 11/26/23.
//

import XCTest
@testable import des

final class BinaryIntegerTests: XCTestCase {
    func test_shouldSplit64() throws {
        let item: UInt64 = 0b10000000_00000000_00000000_00000001_10000000_00000000_00000000_00000000
        let split = item.split()
        XCTAssertEqual(split.0, 0b10000000_00000000_00000000_00000001)
        XCTAssertEqual(split.1, 0b10000000_00000000_00000000_00000000)
    }

    func test_shouldSplit32() throws {
        let item: UInt32 = 0b10000000_00000000_00000000_00000001
        let split = item.split()
        XCTAssertEqual(split.0, 0b10000000_00000000)
        XCTAssertEqual(split.1, 0b00000000_00000001)
    }

    func test_shouldSplit16() throws {
        let item: UInt16 = 0b10000000_00010000
        let split = item.split()
        XCTAssertEqual(split.0, 0b10000000)
        XCTAssertEqual(split.1, 0b00010000)
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

    func test_shouldPadString() throws {
        var myString = "A"
        var paddedA: [UInt8] = [65, 0, 0, 0, 0, 0, 0, 7]
        var data = pad(string: myString, amount: DES.blockSize)
        XCTAssertEqual(data, Data(paddedA))
        myString = "AAAAAAAAA"
        paddedA = [65, 65, 65, 65, 65, 65, 65, 65, 65, 0, 0, 0, 0, 0, 0, 7]
        data = pad(string: myString, amount: DES.blockSize)
        XCTAssertEqual(data, Data(paddedA))
        myString = "AAAAAAAA"
        paddedA = [65, 65, 65, 65, 65, 65, 65, 65]
        data = pad(string: myString, amount: DES.blockSize)
        XCTAssertEqual(data, Data(paddedA))
    }
//
    func test_shouldUnpadString() throws {
        var myString = "12345678"
        var data = try XCTUnwrap(pad(string: myString, amount: DES.blockSize))
        var unpadded = String(unpad(data: data))
        XCTAssertEqual(unpadded, "12345678")

        myString = "AAAAAAAAA"
        data = try XCTUnwrap(pad(string: myString, amount: DES.blockSize))
        unpadded = String(unpad(data: data))
        XCTAssertEqual(unpadded, "AAAAAAAAA")
    }

    func test_shouldConvertToByteArray() throws {
        let myString = "message!"
        let byteArray = convertToByteArray(myString.uint64!)
        XCTAssertEqual(byteArray.count, 8)
        XCTAssertEqual(byteArray, [109, 101, 115, 115, 97, 103, 101, 33])
        //stringBlock    UInt64    4d 65 73 73 61 67 65 21                         Message!
    }
}


