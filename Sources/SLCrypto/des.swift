// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public class DES {
    public let key: UInt64
    var messageBlock: UInt64?
    var cypherBlock: UInt64?
    var pc2List: [UInt64]!
    let initializationVector: UInt64
    let mode: Mode

    public init(key: UInt64 = UInt64.random(in: 0...UInt64.max), mode: Mode = .ECB) {
        self.key = key
        self.mode = mode
        initializationVector = UInt64.random(in: 0...UInt64.max)
        pc2List = generatePC2List()
    }

    public enum Mode {
        case ECB
        case CBC
        case CFB
        case CTS //?
    }

    public static let blockSize: Int = 8

    public func encrypt(_ stringData: Data) -> Data? {
        return encryptFunction(stringData)
    }

    public func decrypt(_ cypherData: Data) -> Data? {
        return decryptFunction(cypherData)
    }

    private func encryptFunction(_ plainText: Data) -> Data {
        switch mode {
        case .ECB:
            return bookCrypt(plainText, setBlock: setMessageBlock, transform: feistelEncryption)
        case .CBC:
            return chainCrypt(plainText, setBlock: setMessageBlock, transform: feistelEncryption, encrypt: true)
        case .CFB:
            return Data()
        case .CTS:
            return Data()
        }
    }

    private func decryptFunction(_ cypherText: Data) -> Data {
        switch mode {
        case .ECB:
            return bookCrypt(cypherText, setBlock: setCyperBlock, transform: feistelDecryption)
        case .CBC:
            return chainCrypt(cypherText, setBlock: setCyperBlock, transform: feistelDecryption, encrypt: false)
        case .CFB:
            return Data()
        case .CTS:
            return Data()
        }
    }

    internal func bookCrypt(_ data: Data, setBlock: (_ block: UInt64) -> Void, transform: () -> UInt64 ) -> Data {
        let blockCount = data.count / 8
        var outData: Data = Data()

        for index in 0..<blockCount {
            let blockIndex = index * DES.blockSize
            let inBlock = data.subdata(in: blockIndex..<(blockIndex + DES.blockSize))
            let block: UInt64 = UInt64(inBlock)

            setBlock(block)
            let stringBlock = transform()

            let byteArray = convertToByteArray(stringBlock)
            outData.append(contentsOf:byteArray)
        }
        return outData
    }

    internal func chainCrypt(_ data: Data, setBlock: (_ block: UInt64) -> Void,
                             transform: () -> UInt64, encrypt: Bool) -> Data {
        let blockCount = data.count / 8
        var outData: Data = Data()
        var vector = initializationVector
        for index in 0..<blockCount {
            let blockIndex = index * DES.blockSize
            let inBlock = data.subdata(in: blockIndex..<(blockIndex + DES.blockSize))
            let block: UInt64 = UInt64(inBlock)
            var stringBlock: UInt64
            if encrypt {
                setBlock(block ^ vector)
                stringBlock = transform()
                vector = stringBlock
            } else {
                setBlock(block)
                stringBlock = (transform() ^ vector)
                vector = block
            }

            let byteArray = convertToByteArray(stringBlock)
            outData.append(contentsOf:byteArray)
        }
        return outData
    }

    internal func setMessageBlock(_ block: UInt64) {
        messageBlock = block
    }

    internal func setCyperBlock(_ block: UInt64) {
        cypherBlock = block
    }

    internal func feistelEncryption() -> UInt64 {
        guard let message = messageBlock else { return 0 }
        return feistel(message, pc2: pc2List)
    }

    internal func feistelDecryption() -> UInt64 {
        guard let cypher = cypherBlock else { return 0 }
        return feistel(cypher, pc2: pc2List.reversed())
    }

    internal func feistel(_ block: UInt64, pc2: [UInt64]) -> UInt64 {
        guard var round = initialPermutation(of: block) else { return 0 }

        for list in pc2 {
            let result = cryptedBlock(input: round, with: list)
            round = combine32Bits(result.0, result.1)
        }

        let swapped = swap64(round)
        let inv = inversePermutation(swapped)
        return inv
    }

    internal func cryptedBlock(input: UInt64, with pc2: UInt64) -> (UInt32, UInt32) {
        let left = input.split().0
        let right = input.split().1

        let rExp = expansion(right)
        let xOR = rExp ^ pc2

        // do s-box stuff
        let sOut = sBox(xOR)

        // permutate
        let permutation = permutate(sOut)

        // x-or with l
        let xOR2 = permutation ^ left

        // new r
        return (right, xOR2)
    }

    internal func shiftAndCombineKVals(_ left: UInt32, _ right: UInt32, amount: Int = 1) -> UInt64? {
        guard let left = singleLeftshift(left) else { return nil }
        guard let right = singleLeftshift(right) else { return nil }
        return combineKVals(UInt64(left), UInt64(right))
    }

    internal func generatePC2List() -> [UInt64] {
        var list: [UInt64] = [UInt64]()
        var kL: UInt32
        var kR: UInt32
        kL = pc1Left
        kR = pc1Right
        for i in 1...16 {
            var tempLeft: UInt32
            var tempRight: UInt32
            if DES.iterationShifts[i] == 2 {
                tempLeft = doubleLeftshift(kL) ?? 0
                tempRight = doubleLeftshift(kR) ?? 0
            } else {
                tempLeft = singleLeftshift(kL) ?? 0
                tempRight = singleLeftshift(kR) ?? 0
            }
            list.append(pc2Create(tempLeft, tempRight))
            kL = tempLeft
            kR = tempRight
        }
        return list
    }

    internal func combineKVals(_ left: UInt64, _ right: UInt64) -> UInt64 {
        var left = left << 28
        left = leftCirShift(left)
        let right = leftCirShift(right)
        return (left | right)
    }

    internal func genKey() -> UInt64 {
        let left = UInt64(pc1Left << 28)
        let right = UInt64(pc1Right)
        return (left | right)
    }

    internal func initialPermutation(of block: UInt64) -> UInt64? {
        var pc1: UInt64 = 0
        for location in DES.ip.values.enumerated() {
            let loc = UInt64(location.offset)
            var val = UInt64(block.getBit(UInt64(location.element)))
            val = (val << (63 - loc))
            pc1 = pc1 | val
        }
        return pc1
    }

    internal func expansion(_ bit32: UInt32) -> UInt64 {
        var pc1: UInt64 = 0
        for location in DES.e_bit.values.enumerated() {
            let loc = UInt32(location.offset)
            var val = UInt64(bit32.getBit(UInt32(location.element)))
            val = val << (47 - loc)
            pc1 = pc1 | UInt64(val)
        }
        return pc1
    }

    internal func permutate(_ bit32: UInt32) -> UInt32 {
        var out32: UInt32 = 0
        for location in DES.p.values.enumerated() {
            let loc = UInt32(location.offset)
            var val = UInt32(bit32.getBit(UInt32(location.element)))
            val = val << (31 - loc)
            out32 = out32 | val
        }
        return out32
    }

    internal func sfunction(_ bit8: UInt8, sTable: BITable ) -> UInt8? {
        let r1 = bit8.getBit(3)
        let r2 = bit8.getBit(8)
        let row = (r1 << 1) | r2
        // 1234_5678 -> 4567_8000 -> 0004_567
        let column = (bit8 << 3) >> 4
        let index = (row * 16) + column
        let value = sTable.lookup(Int(index)) as? UInt8
        return value
    }

    internal func break48Into6Bits(_ bit48: UInt64) -> [UInt8] {
        var output: [UInt8] = [UInt8]()
        for i in stride(from: 16, to: 64, by: 6) {
            let bit4 = UInt8((bit48 << i) >> 58)
            output.append(bit4)
        }
        return output
    }

    internal func sBox(_ bit48: UInt64) -> UInt32 {
        var sOut: UInt32 = 0
        var shiftAmount: UInt32 = 28
        // 28 24 20 16 12 8 4 0
        let sBoxInput: [UInt8] = break48Into6Bits(bit48)
        for box in sBoxInput.enumerated() {
            let byte: UInt8 = box.element
            guard let sComp = sfunction(byte, sTable: DES.S_Tables[box.offset]) else {
                return 0 }
            var sTemp = UInt32(sComp)
            // shift each successive sComp left by
            // need to make sComp a 32 bit number
            sTemp = sTemp << shiftAmount
            shiftAmount -=  shiftAmount > 3 ? 4 : 0 // don't break UInt32
            sOut |= UInt32(sTemp)
        }
        // each set of 6 bits, map them into the next sfunction
        // save them and put them into a new 32bit
        return sOut
    }

    internal func inversePermutation(_ bit64: UInt64) -> UInt64 {
        var output: UInt64 = 0
        for location in DES.ip_inv.values.enumerated() {
            let loc = UInt64(location.offset)
            var val = UInt64(bit64.getBit(UInt64(location.element)))
            val = (val << (63 - loc))
            output = output | val
        }
        return output
    }

    internal var pc1Left: UInt32 {
        var pc1: UInt32 = 0
        for location in DES.pc1_left.values.enumerated() {
            let loc = UInt32(location.offset)
            var val = UInt32(key.getBit(UInt64(location.element)))
            val = val << (27 - loc)
            pc1 = pc1 | val
        }
        return pc1
    }

    internal var pc1Right: UInt32 {
        var pc1: UInt32 = 0
        for location in DES.pc1_right.values.enumerated() {
            let loc = UInt32(location.offset)
            var val = UInt32(key.getBit(UInt64(location.element)))
            val = val << (27 - loc)
            pc1 = pc1 | val
        }
        return pc1
    }

    internal func pc2Create(_ bit56: UInt64) -> UInt64 {
        var pc2: UInt64 = 0
        for location in DES.pc2.values.enumerated() {
            let loc = UInt64(location.offset)
            var val = UInt64(bit56.getBit(UInt64(Int(location.element) + 8)))
            val = val << (47 - loc)
            pc2 = pc2 | val
        }
        return pc2
    }

    internal func pc2Create(_ left: UInt32, _ right: UInt32) -> UInt64 {
        let leftShifted:UInt64 = UInt64(left) << 28
        let combined = leftShifted | UInt64(right)
        return pc2Create(combined)
    }
}

extension DES {
    static let iterationShifts = {
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
        let table: [UInt8] = [40, 8, 48, 16, 56, 24, 64, 32,
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

    static let pc2: BITable = {
        let table: [UInt8] = [
            14, 17, 11, 24, 1, 5,
            3, 28, 15, 6, 21, 10,
            23, 19, 12, 4, 26, 8,
            16, 7, 27, 20, 13, 2,
            41, 52, 31, 37, 47, 55,
            30, 40, 51, 45, 33, 48,
            44, 49, 39, 56, 34, 53,
            46, 42, 50, 36, 29, 32]
        return BITable(values: table)
    }()

    static let s1: BITable = {
        let table: [UInt8] = [
            14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7,
            0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8,
            4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0,
            15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13]
        return BITable(values: table)
    }()

    static let s2: BITable = {
        let table: [UInt8] = [
            15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10,
            3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5,
            0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15,
            13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9]
        return BITable(values: table)
    }()

    static let s3: BITable = {
        let table: [UInt8] = [
            10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8,
            13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1,
            13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7,
            1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12]
        return BITable(values: table)
    }()

    static let s4: BITable = {
        let table: [UInt8] = [
            7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15,
            13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9,
            10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4,
            3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14]
        return BITable(values: table)
    }()

    static let s5: BITable = {
        let table: [UInt8] = [
            2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9,
            14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6,
            4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14,
            11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3
            ]
        return BITable(values: table)
    }()

    static let s6: BITable = {
        let table: [UInt8] = [
            12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11,
            10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8,
            9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6,
            4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13
            ]
        return BITable(values: table)
    }()

    static let s7: BITable = {
        let table: [UInt8] = [
            4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1,
            13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6,
            1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2,
            6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12
            ]
        return BITable(values: table)
    }()

    static let s8: BITable = {
        let table: [UInt8] = [
            13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7,
            1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2,
            7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8,
            2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11
        ]
        return BITable(values: table)
    }()

    static let S_Tables: [BITable] = [s1, s2, s3, s4, s5, s6, s7, s8]
}
