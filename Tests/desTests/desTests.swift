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
        let value: UInt64 = 0b1000000000000000000000000000000000000000000000000000000000000001
        var bit = value.getBit(1)
        for i in 0..<64 {
            print("Index: \(i) : \(value.getBit(UInt64(i)))")
        }
        XCTAssertEqual(bit, 1)
        bit = value.getBit(33)
        XCTAssertEqual(bit, 0)
        bit = value.getBit(64)
        XCTAssertEqual(bit, 1)
    }

    func test_shouldPC1OfKey() throws {
        print(testBits)
        var sut = DES(key: testBits)
        var pc1 = sut.pc1_left
        print(pc1)
        XCTAssertEqual(pc1, 0b0000111100001111000011110000)

        pc1 = sut.pc1_right
        XCTAssertEqual(pc1, 0b0000111100001111000011111111)

        let testKey = "TestKeys"
        let binary = testKey.uint64
    }

    func test_shouldConvert64BitStringToUInt64() throws {
        let testString = "TestKeys"
        let binaryString = try XCTUnwrap(testString.uint64)
        let string = String(binaryString)
        XCTAssertEqual(string, testString)
    }
}


extension String {
    var uint64: UInt64? {
        guard let data = self.data(using: .utf8) else { return nil }
        return data.withUnsafeBytes { $0.load(as: UInt64.self) }
    }

    init(_ uint64: UInt64) {
        var byteArray: [UInt8] = Array(repeating: 0, count: MemoryLayout<UInt64>.size)
        withUnsafeBytes(of: uint64) { rawBufferPointer in
            if let baseAddress = rawBufferPointer.baseAddress {
                byteArray.withUnsafeMutableBytes { mutableRawBufferPointer in
                    mutableRawBufferPointer.copyMemory(from: UnsafeRawBufferPointer(start: baseAddress, count: MemoryLayout<UInt64>.size))
                }
            }
        }
        self = String(bytes: byteArray, encoding: .utf8) ?? ""
    }

    static func fromUInt64(_ uint64: UInt64) -> String? {
        var byteArray: [UInt8] = Array(repeating: 0, count: MemoryLayout<UInt64>.size)
        withUnsafeBytes(of: uint64) { rawBufferPointer in
            if let baseAddress = rawBufferPointer.baseAddress {
                byteArray.withUnsafeMutableBytes { mutableRawBufferPointer in
                    mutableRawBufferPointer.copyMemory(from: UnsafeRawBufferPointer(start: baseAddress, count: MemoryLayout<UInt64>.size))
                }
            }
        }
        return String(bytes: byteArray, encoding: .utf8)
    }
}
