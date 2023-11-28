//
//  File.swift
//  
//
//  Created by Jericho Hasselbush on 11/26/23.
//

import Foundation
import des

let des1 = DES()
let message = "HeyaayeH".uint64!
des1.setMessageBlock(message)
let cyphertext = des1.encryptBlock()
des1.setCyperBlock(cyphertext)
let plaintext = des1.decryptBlock()

print(String(message) + " " + String(plaintext))

print(String(tripleDESTripleKey("AGUNSKY!".uint64!)))

func tripleDESTripleKey(_ message: UInt64) -> UInt64 {
    let des1 = DES()
    let des2 = DES()
    let des3 = DES()

    // encrypt
    des1.setMessageBlock(message)
    var cypher = des1.encryptBlock()
    des2.setCyperBlock(cypher)
    cypher = des2.decryptBlock()
    des3.setMessageBlock(cypher)
    cypher = des3.encryptBlock()

    // decrypt
    des3.setCyperBlock(cypher)
    var plain = des3.decryptBlock()
    des2.setMessageBlock(plain)
    plain = des2.encryptBlock()
    des1.setCyperBlock(plain)
    plain = des1.decryptBlock()

    return plain
}
// TODO:
// - 64bit padding
// - make way to handle long string of input

