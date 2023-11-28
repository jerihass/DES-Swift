//
//  File.swift
//  
//
//  Created by Jericho Hasselbush on 11/26/23.
//

import Foundation
import des

let des1 = DES()
let message = "HeyaayeH"
let cyphertext = des1.encrypt(pad(string: message, amount: DES.blockSize) ?? Data())
let plaintext = des1.decrypt(cyphertext ?? Data())

print(String(message) + " " + String(unpad(data: plaintext ?? Data())))

// TODO:
// - 64bit padding pad("string", block_size) = 'string\0\2'
// - make way to handle long string of input
// ✅ ECB MODE -- no IV
// ☑️ CBC MODE -- ?
// ☑️ CFB MODE?
// ☑️ CTS MODE?

