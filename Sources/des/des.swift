// The Swift Programming Language
// https://docs.swift.org/swift-book


func leftCirShift(_ bits: UInt64, by: Int = 0) -> UInt64 {
    var shift: UInt64 = 0
    shift = bits << by
    return shift
}

infix operator <<<
infix operator >>>

extension BinaryInteger {
    
    /// Left circular shift
    /// - Parameters:
    ///   - lhs: Binary Integer to shift
    ///   - rhs: places to shift
    /// - Returns: Left circular shifts: 0b1011 -> 0b0111
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
    static func >>> <RHS>(lhs: inout Self, rhs: RHS) -> Self where RHS: BinaryInteger {
        let shiftCount = Int(rhs) % lhs.bitWidth
        if shiftCount > 0 {
            let shifted = (lhs >> shiftCount) | (lhs << (lhs.bitWidth - shiftCount))
            lhs = shifted
        }
        return lhs
    }
}
