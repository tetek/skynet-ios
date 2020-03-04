//
//  Manager.swift
//  Skynet
//
//  Created by Wojciech Mandrysz on 02/03/2020.
//  Copyright © 2020 Wojciech Mandrysz. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

let KeyHistory = "history_data"
let AppGroupName = "group.tech.sia.skynet"
let KeyPortal = "current_portal"
let KeyExpectedDownloads = "expected_downloads"
let MaxHistory = 100

class Manager: ObservableObject {
    static let shared = Manager()
    private init() {}
    @Published var history: [Skylink] = load()

    func add(skylink: Skylink) {
        history.insert(skylink, at: 0)
        Manager.save(array: history)
    }

    class func save(array: [Skylink]) {
        let latest = array.prefix(upTo: min(MaxHistory, array.count))
        let data = latest.map { try? JSONEncoder().encode($0) }
        let ud = UserDefaults(suiteName: AppGroupName)
        ud?.set(data, forKey: KeyHistory)
        ud?.synchronize()
    }

    func reload() {
        history = Manager.load()
    }

    class func load() -> [Skylink] {
        let ud = UserDefaults(suiteName: AppGroupName)
        guard let encodedData = ud?.array(forKey: KeyHistory) as? [Data] else {
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
