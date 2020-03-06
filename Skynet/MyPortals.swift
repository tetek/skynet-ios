//
//  MyPortals.swift
//  Skynet
//
//  Created by Wojciech Mandrysz on 05/03/2020.
//  Copyright © 2020 Wojciech Mandrysz. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

let KeyMyPortals = "my_portals"
let MaxPortals = 10

class MyPortals: ObservableObject {
    static let shared = MyPortals()
    private init() {}
    @Published var portals: [Portal] = load()

    func add(portal: Portal) {
        portals.insert(portal, at: 0)
        MyPortals.save(array: portals)
    }

    class func save(array: [Portal]) {
        let latest = array.prefix(upTo: min(MaxPortals, array.count))
        let data = latest.map { try? JSONEncoder().encode($0) }
        let ud = UserDefaults(suiteName: AppGroupName)
        ud?.set(data, forKey: KeyMyPortals)
        ud?.synchronize()
    }

    func reload() {
        portals = MyPortals.load()
    }

    class func load() -> [Portal] {
        let ud = UserDefaults(suiteName: AppGroupName)
        guard let encodedData = ud?.array(forKey: KeyMyPortals) as? [Data] else {
            return []
        }

        return encodedData.map { try! JSONDecoder().decode(Portal.self, from: $0) }
    }
}
