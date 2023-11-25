//
//  Created by Jericho Hasselbush on 11/25/23.
//

import Foundation

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
}
