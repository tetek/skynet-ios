//
//  Portal.swift
//  Skynet
//
//  Created by Wojciech Mandrysz on 01/03/2020.
//  Copyright © 2020 Wojciech Mandrysz. All rights reserved.
//

import Foundation
import SwiftUI

struct Portal: Identifiable, Codable {
    
    var id: String { return host }
    let host: String
    let uploadPath: String
    let downloadPath: String
    let name: String
    
    
    init(name: String, host: String, uploadPath: String, downloadPath: String = "") {
        self.name = name
        self.host = host
        self.uploadPath = uploadPath
        self.downloadPath = downloadPath
    }
    
    func newUploadURL() -> URL {
        let uuid = UUID().uuidString
        return URL(string: host)!.appendingPathComponent(uploadPath).appendingPathComponent(uuid)
    }
    
    func downloadURL(skylink: String) -> URL {
        return URL(string: host)!.appendingPathComponent(downloadPath).appendingPathComponent(skylink)
    }
}

