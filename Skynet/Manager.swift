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
    static let KeyPortal = "current_portal"

    class func add(skylink: Skylink) {
        history.insert(skylink, at: 0)
        save()
    }

    class func save() {
        let data = history.map { try? JSONEncoder().encode($0) }
        let ud = UserDefaults(suiteName: AppGroupName)
        ud?.set(data, forKey: KeyForUserDefaults)
        ud?.synchronize()
    }

    class func load() -> [Skylink] {
        let ud = UserDefaults(suiteName: AppGroupName)
        guard let encodedData = ud?.array(forKey: KeyForUserDefaults) as? [Data] else {
            return []
        }

        return encodedData.map { try! JSONDecoder().decode(Skylink.self, from: $0) }
    }
    static var currentPortal: Portal {
        get {
            let ud = UserDefaults(suiteName: AppGroupName)
            guard let data = ud?.data(forKey: KeyPortal) else {
                return Portal(name: "Sia Skynet", host: "https://siasky.net/", uploadPath: "skynet/skyfile")
            }
            return try! JSONDecoder().decode(Portal.self, from: data)
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            let ud = UserDefaults(suiteName: AppGroupName)
            ud?.set(data, forKey: KeyPortal)
            ud?.synchronize()
        }        
    }

}
