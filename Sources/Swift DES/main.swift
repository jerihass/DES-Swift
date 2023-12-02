//
//  File.swift
//  
//
//  Created by Jericho Hasselbush on 11/26/23.
//

import Foundation
import des

let des1 = DES(mode: .CBC)
let message = "This is a longer message of some length that we aren't checking! 🥸"
let cyphertext = des1.encrypt(pad(string: message, amount: DES.blockSize) ?? Data())
let plaintext = des1.decrypt(cyphertext ?? Data())

print(String(message) + "\n" + String(unpad(data: plaintext ?? Data())))

// TODO:
// ☑️ Triple / Multi DES
// ✅ ECB MODE
// ✅ CBC MODE
// ☑️ CFB MODE?
// ☑️ CTS MODE?

