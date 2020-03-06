//
//  PortalsView.swift
//  Skynet
//
//  Created by Wojciech Mandrysz on 02/03/2020.
//  Copyright © 2020 Wojciech Mandrysz. All rights reserved.
//

import Foundation
import SwiftUI

struct PortalView: View {
    let portal: Portal
    @EnvironmentObject var manager: Manager
    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(3)) {
            Text(portal.name).font(.headline)
            Text(portal.host).font(.subheadline)
        }
        .onTapGesture {
            Manager.currentPortal = self.portal
            Manager.shared.reload()
//            self.currentPortal = self.portal
        }
    }
}

struct PortalsView: View {
    var portals: [Portal] = [
        Portal(name: "Sia Skynet", host: "https://siasky.net/", uploadPath: "skynet/skyfile"),
        Portal(name: "Skydrain", host: "https://skydrain.net/", uploadPath: "skynet/skyfile"),
        Portal(name: "Sialopp", host: "https://sialoop.net/", uploadPath: "skynet/skyfile"),
        Portal(name: "Skynet Luxor", host: "https://skynet.luxor.tech/", uploadPath: "skynet/skyfile"),
        Portal(name: "Tutemwesi", host: "https://skynet.tutemwesi.com/", uploadPath: "skynet/skyfile"),
        Portal(name: "Sia CDN", host: "https://siacdn.com/", uploadPath: "skynet/skyfile"),
    ]
//    @State var current: Portal
    @EnvironmentObject var myPortals: MyPortals
    @EnvironmentObject var manager: Manager

    var body: some View {
        List {
            Section(header: Text("Using")) {
                PortalView(portal: manager.current)
            }
            if myPortals.portals.filter({ $0.host != manager.current.host }).count > 0 {
                Section(header: Text("My portals")) {
                    ForEach(myPortals.portals.filter({ $0.host != manager.current.host })) { portal in
                        PortalView(portal: portal)
                    }
                    .onDelete(perform: delete(at:))
                }
            }
            Section(header: Text("Other")) {
                ForEach(portals.filter({ $0.host != manager.current.host })) { portal in
                    PortalView(portal: portal)
                }
            }
        }

        .listStyle(GroupedListStyle())
        .navigationBarTitle("Portals")

        .navigationBarItems(trailing:
            NavigationLink(destination: AddPortalView()) {
                Image(systemName: "plus.circle.fill").font(Font.system(.largeTitle))
        })
    }

    func delete(at offsets: IndexSet) {
        var p = MyPortals.shared.portals.filter({ $0.host != manager.current.host })
        offsets.forEach({ p.remove(at: $0) })

        MyPortals.save(array: p)
        MyPortals.shared.reload()
//        users.remove(atOffsets: offsets)
    }
}
