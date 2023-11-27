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
}
