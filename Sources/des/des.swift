// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

class DES {
    let key: UInt64
    var messageBlock: UInt64?

    init(key: UInt64) {
        self.key = key
    }

    func setBlock(_ block: UInt64) {
        messageBlock = block
    }

    internal func initialPermutation() -> UInt64? {
        guard let message = messageBlock else { return nil }
        var pc1: UInt64 = 0
        for location in DES.ip.values.enumerated() {
            let loc = UInt8(location.offset)
            var val = UInt64(message.getBit(UInt64(location.element)))
            val = (val << (63 - loc))
            pc1 = pc1 | val
        }
        return pc1
    }

    internal var pc1_left: UInt32 {
        var pc1: UInt32 = 0
        for location in DES.pc1_left.values.enumerated() {
            let loc = UInt8(location.offset)
            var val = UInt32(key.getBit(UInt64(location.element)))
            val = val << (27 - loc)
            pc1 = pc1 | val
        }
        return pc1
    }

    internal var pc1_right: UInt32 {
        var pc1: UInt32 = 0
        for location in DES.pc1_right.values.enumerated() {
            let loc = UInt8(location.offset)
            var val = UInt32(key.getBit(UInt64(location.element)))
            val = val << (27 - loc)
            pc1 = pc1 | val
        }
        return pc1
    }
}

extension DES {
    static let interationShifts = {
        var dict: [Int:Int] = [:]
        dict[1] = 1
        dict[2] = 1
        dict[3] = 2
        dict[4] = 2
        dict[5] = 2
        dict[6] = 2
        dict[7] = 2
        dict[8] = 2
        dict[9] = 1
        dict[10] = 2
        dict[11] = 2
        dict[12] = 2
        dict[13] = 2
        dict[14] = 2
        dict[15] = 2
        dict[16] = 1
        return dict
    }()

    static let ip: BITable = {
        let table: [UInt8] = [58, 50, 42, 34, 26, 18, 10, 2,
                              60, 52, 44, 36, 28, 20, 12, 4,
                              62, 54, 46, 38, 30, 22, 14, 6,
                              64, 56, 48, 40, 32, 24, 16, 8,
                              57, 49, 41, 33, 25, 17, 9, 1,
                              59, 51, 43, 35, 27, 19, 11 , 3,
                              61, 53, 45, 37, 29, 21, 13 , 5,
                              63, 55, 47, 39, 31, 23, 15 , 7]
        return BITable(values: table)}()

    static let ip_inv: BITable = {
        let table: [UInt8] = [40, 8, 48, 16, 56, 14, 64, 32,
                              39, 7, 47, 15, 55, 23, 63, 31,
                              38, 6, 46, 14, 54, 22, 62, 30,
                              37, 5, 45, 13, 53, 21, 61, 29,
                              36, 4, 44, 12, 52, 20, 60, 28,
                              35, 3, 43, 11, 51, 19, 59, 27,
                              34, 2, 42, 10, 50, 18, 58, 26,
                              33, 1, 41, 9, 49, 17, 57, 25]
        return BITable(values: table)}()

    static let e_bit: BITable = {
        let table: [UInt8] = [32, 1, 2, 3, 4, 5,
                              4, 5, 6, 7, 8, 9,
                              8, 9, 10, 11, 12, 13,
                              12, 13, 14, 15, 16, 17,
                              16, 17, 18, 19, 20, 21,
                              20, 21, 22, 23, 24, 25,
                              24, 25, 26, 27, 28, 29,
                              28, 29, 30, 31, 32, 1]
        return BITable(values: table)}()

    static let p: BITable = {
        let table: [UInt8] = [16, 7, 20, 21,
                              29, 12, 28, 17,
                              1, 15, 23, 26,
                              5, 18, 31, 10,
                              2, 8, 24, 14,
                              32, 27, 3, 9,
                              19, 13, 30, 6,
                              22, 11, 4, 25]
        return BITable(values: table)}()

    static let pc1_left: BITable = {
        let table: [UInt8] = [57, 49, 41, 33, 25, 17, 9,
                              1, 58, 50, 42, 34, 26, 18,
                              10, 2, 59, 51, 43, 35, 27,
                              19, 11, 3, 60, 52, 44, 36]
        return BITable(values: table)}()

    static let pc1_right: BITable = {
        let table: [UInt8] = [63, 55, 47, 39, 31, 23, 15,
                              7, 62, 54, 46, 38, 30, 22,
                              14, 6, 61, 53, 45, 37, 29,
                              21, 13, 5, 28, 20, 12, 4]
        return BITable(values: table)}()
}
