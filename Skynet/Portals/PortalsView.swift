//
//  ContentView.swift
//  Skynet
//
//  Created by Wojciech Mandrysz on 29/02/2020.
//  Copyright © 2020 Wojciech Mandrysz. All rights reserved.
//

import SwiftUI

struct PortalsView: View {
    let portals: [Portal] = [Portal(name: "Sia Skynet", host: "https://siasky.net/", uploadPath: "skynet/skyfile/")]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(portals) { portal in
                   PortalView(portal: portal)
                }
            }
            .navigationBarTitle(Text("Portals"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PortalsView()
    }
}
