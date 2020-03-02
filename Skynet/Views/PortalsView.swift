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
    @Binding var currentPortal: Portal
    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat(3)) {
            Text(portal.name).font(.headline)
            Text(portal.host).font(.subheadline)
        }
        .onTapGesture {
            self.currentPortal = self.portal
            Manager.currentPortal = self.portal
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
    @State var current: Portal = Manager.currentPortal
    var body: some View {
        List {
            Section(header: Text("Using")) {
                PortalView(portal: current, currentPortal: self.$current)
            }
            Section(header: Text("Other")) {
                ForEach(portals.filter({ $0.host != current.host })) { portal in
                    PortalView(portal: portal, currentPortal: self.$current)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Portals")
    }
}
