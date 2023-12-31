//
//  Created by Jericho Hasselbush on 11/28/23.
//

import Foundation

public func pad(string: String, amount: Int) -> Data? {
    guard var data = string.data(using: .utf8) else { return nil }
    if data.count % amount != 0 {
        let fillCount: Int = amount - (data.count % amount) - 1
        var fill: [UInt8] = [UInt8](repeating: 0, count: fillCount)
        fill.append(UInt8(fillCount + 1))
        data.append(contentsOf: fill)
    }
    return data
}

public func unpad(data: Data) -> String {
    guard let lastByte = data.last else { return "" }
    if (lastByte > 0 && lastByte < 8) {
        var actual = data.dropLast(Int(lastByte)).compactMap({UInt8($0)})
        actual.append(UInt8())
        return String(cString: actual)
    }
    var temp = data
    temp.append(UInt8())
    return String(cString: temp.compactMap({UInt8($0)}))
}

func convertToByteArray(_ block: UInt64) -> [UInt8] {
//    var byteArray: [UInt8] = Array(repeating: 0, count: MemoryLayout<UInt64>.size)
//    withUnsafeBytes(of: block) { rawBufferPointer in
//        if let baseAddress = rawBufferPointer.baseAddress {
//            byteArray.withUnsafeMutableBytes { mutableRawBufferPointer in
//                mutableRawBufferPointer.copyMemory(from: UnsafeRawBufferPointer(start: baseAddress, count: MemoryLayout<UInt64>.size))
//            }
//        }
//    }
//    return byteArray
    var result: [UInt8] = []

    for i in 0..<8 {
        let byte = UInt8((block >> (8 * i)) & 0xFF)
        result.append(byte)
    }

    return result
}
