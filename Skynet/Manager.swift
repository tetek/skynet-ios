//
//  Manager.swift
//  Skynet
//
//  Created by Wojciech Mandrysz on 02/03/2020.
//  Copyright © 2020 Wojciech Mandrysz. All rights reserved.
//

import Foundation

class Manager {
    static var history: [Skylink] = load()
    static let KeyForUserDefaults = "history_data"
    static let AppGroupName = "group.tech.sia.skynet"
    
    class func add(skylink: Skylink) {
        history.insert(skylink, at: 0)
        save()
    }
    
    class func save() {
        let data = history.map { try? JSONEncoder().encode($0) }
        let ud = UserDefaults.init(suiteName: AppGroupName)
        ud?.set(data, forKey: KeyForUserDefaults)
        ud?.synchronize()
    }

    class func load() -> [Skylink] {
        let ud = UserDefaults.init(suiteName: AppGroupName)
        guard let encodedData = ud?.array(forKey: KeyForUserDefaults) as? [Data] else {
            return []
        }

        return encodedData.map { try! JSONDecoder().decode(Skylink.self, from: $0) }
    }
}


