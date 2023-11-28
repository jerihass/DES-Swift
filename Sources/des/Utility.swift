//
//  Created by Jericho Hasselbush on 11/28/23.
//

import Foundation

func pad(string: String, amount: Int) -> Data? {
    guard var data = string.data(using: .utf8) else { return nil }
    if data.count % amount != 0 {
        let fillCount: Int = amount - (data.count % amount) - 1
        var fill: [UInt8] = [UInt8](repeating: 0, count: fillCount)
        fill.append(UInt8(fillCount + 1))
        data.append(contentsOf: fill)
    }
    return data
}

func unpad(data: Data) -> String {
    guard let lastByte = data.last else { return "" }
    if (lastByte > 0 && lastByte < 8) {
        var actual = data.dropLast(Int(lastByte)).compactMap({UInt8($0)})
        actual.append(UInt8())
        return String(cString: actual)
    }
    return ""
}
