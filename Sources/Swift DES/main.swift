//
//  File.swift
//  
//
//  Created by Jericho Hasselbush on 11/26/23.
//

import Foundation
import des

let des = DES(key: 0)
des.setCyperBlock(0)
des.setMessageBlock(0)
let val = des.encryptBlock()
print(val)
