//
//  ContentView.swift
//  Skynet
//
//  Created by Wojciech Mandrysz on 29/02/2020.
//  Copyright © 2020 Wojciech Mandrysz. All rights reserved.
//

import SwiftUI
// Row
struct SkylinkView: View {
    let skylink: Skylink

    var body: some View {
        
        HStack(alignment: .top, spacing: CGFloat(3)) {
            VStack(alignment: .leading, spacing: CGFloat(3)) {
                Text(skylink.filename).font(.headline)
                Text(skylink.link).font(.subheadline)
            }
            Text("Copy").foregroundColor(.green)
        }
        
    }
}

// List
struct SkylinksView: View {
    @State var skylinks: [Skylink] = Manager.load()
    var body: some View {
        NavigationView {
            
            List(skylinks) { skylink in 
                SkylinkView(skylink: skylink)
            }
        .onAppear(perform: fetch)
            .navigationBarTitle(Text("Skylinks"))
        .navigationBarItems(leading: Button(action: fetch) {
            Text("Reload")
            .font(.title)
            .foregroundColor(.green)
        })
        }
    }
    func fetch() -> Void {
        skylinks = Manager.load()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SkylinksView()
    }
}
