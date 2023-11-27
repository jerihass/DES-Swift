//
//  Created by Jericho Hasselbush on 11/25/23.
//

import Foundation

infix operator <<<
infix operator >>>

extension BinaryInteger {

    /// Left circular shift
    /// - Parameters:
    ///   - lhs: Binary Integer to shift
    ///   - rhs: places to shift
    /// - Returns: Left circular shifts: 0b1011 -> 0b0111
    mutating func lcs(by: Self) -> Self { self <<< by }
    static func <<< <RHS>(lhs: inout Self, rhs: RHS) -> Self where RHS: BinaryInteger {
        let shiftCount = Int(rhs) % lhs.bitWidth
        if shiftCount > 0 {
            let shifted = (lhs << shiftCount) | (lhs >> (lhs.bitWidth - shiftCount))
            lhs = shifted
        }
        return lhs
    }

    /// Right circular shift
    /// - Parameters:
    ///   - lhs: Binary Integer to shift
    ///   - rhs: places to shift
    /// - Returns: Right circular shifts: 0b1011 -> 0b1101
    ///
    mutating func rcs(by: Self) -> Self { self >>> by }
    static func >>> <RHS>(lhs: inout Self, rhs: RHS) -> Self where RHS: BinaryInteger {
        let shiftCount = Int(rhs) % lhs.bitWidth
        if shiftCount > 0 {
            let shifted = (lhs >> shiftCount) | (lhs << (lhs.bitWidth - shiftCount))
            lhs = shifted
        }
        return lhs
    }


    /// GetBit
    /// - Parameter position: position at location from 1-size of item in bits left to right
    /// - Returns: gets the value as a 1 or zero at that position
    func getBit(_ position: Self) -> Self {
        let value = self >> (self.bitWidth - Int(position)) & 1
        return value
    }
}

func singleLeftshift(_ value: UInt32, bitPosition: Int = 28) -> UInt32? {
    let width = value.bitWidth
    guard bitPosition < width else { return nil }
    let position = bitPosition - 1
    var shifted = value
    let bitToMove = value.getBit(UInt32(width - position))
    shifted = shifted << 5
    shifted = shifted >> 4
    shifted = shifted | bitToMove
    return shifted
}

func doubleLeftshift(_ value: UInt32, bitPosition: Int = 28) -> UInt32? {
    guard let value = singleLeftshift(value) else { return nil }
    return singleLeftshift(value)
}

func swap64(_ value: UInt64) -> UInt64 {
    return (value << 32) | (value >> 32)
}

func combine32Bits(_ left: UInt32, _ right: UInt32) -> UInt64 {
    return (UInt64(UInt64(left) << 32) | UInt64(right))
}

func leftCirShift(_ bits: UInt64, by: Int = 0) -> UInt64 {
    var shift: UInt64 = 0
    shift = bits << by
    return shift
}

extension UInt64 {
    func split() -> (UInt32, UInt32) {
        let fraction = self.bitWidth / 2
        let left = UInt32(self &>> fraction)
        let right = UInt32(((self &<< fraction) >> fraction))
        return (left, right)
    }
}

extension UInt32 {
    func split() -> (UInt16, UInt16) {
        let fraction = self.bitWidth / 2
        let left = UInt16(self &>> fraction)
        let right = UInt16(((self &<< fraction) >> fraction))
        return (left, right)
    }
}
extension UInt16 {
    func split() -> (UInt8, UInt8) {
        let fraction = self.bitWidth / 2
        let left = UInt8(self &>> fraction)
        let right = UInt8(((self &<< fraction) >> fraction))
        return (left, right)
    }
}

struct BITable {
    var values: [any BinaryInteger]
    func lookup(_ index: Int) -> (any BinaryInteger)? {
        guard index < values.count else { return nil }
        return values[index]
    }
}
