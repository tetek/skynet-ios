//
//  Skylink.swift
//  Skynet
//
//  Created by Wojciech Mandrysz on 02/03/2020.
//  Copyright © 2020 Wojciech Mandrysz. All rights reserved.
//

import Foundation
import SwiftUI

struct Skylink: Identifiable, Codable {
    let link: String
    let filename: String
    let timestamp: Date = Date()
    var id: String {
        get {
            return link
        }
    }
//    init(link: String, filename: String) {
//        self.link = link
//        self.filename = filename
//        self.timestamp = Date()
//    }
    
}
