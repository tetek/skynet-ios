//
//  ContentView.swift
//  Skynet
//
//  Created by Wojciech Mandrysz on 29/02/2020.
//  Copyright © 2020 Wojciech Mandrysz. All rights reserved.
//

import SafariServices
import SwiftUI
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }
}

// Row
struct SkylinkView: View {
    let skylink: Skylink
    @State var copied: Bool = false
    @State var showSafari = false

    var body: some View {
        HStack(alignment: .top, spacing: CGFloat(3)) {
            VStack(alignment: .leading, spacing: CGFloat(3)) {
                Text(skylink.filename).font(.headline)
                Text(skylink.timestamp.timeAgo() + " via " + skylink.portalName).font(.subheadline).foregroundColor(.gray)
            }

            Spacer()
            if copied {
                Text("Copied!")
                    .foregroundColor(.green)
                    .padding(6.0)
                    .transition(.slide)
            }
        }
        .onTapGesture {
            self.showSafari = true
        }
        .contextMenu {
            Button("Copy http link 🌍") {
                let pb = UIPasteboard.general
                pb.string = Manager.shared.current.downloadURL(skylink: self.skylink.link).absoluteString
            }
            Button("Copy skylink 🆒") {
                let pb = UIPasteboard.general
                pb.string = self.skylink.skylink
            }
            Button("Open link 💻") {
                self.showSafari = true
            }
        }
        .sheet(isPresented: $showSafari) {
            SafariView(url: Manager.shared.current.downloadURL(skylink: self.skylink.link))
        }
    }
}

// List
struct SkylinksView: View {
    @EnvironmentObject var manager: Manager
    
    var body: some View {
        NavigationView {
            List(manager.history) { skylink in
                SkylinkView(skylink: skylink)
            }
            .navigationBarTitle(Text("Skylinks"))
            .navigationBarItems(trailing:
                NavigationLink(destination: PortalsView()) {
                    Image(systemName: "hexagon.fill").font(Font.system(.largeTitle))
                }
            )
        }.accentColor(Color(red: 0x57/0xFF, green: 0xb5/0xFF, blue: 0x60/0xFF))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SkylinksView()
    }
}
