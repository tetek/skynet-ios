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
    @State var showSafari = false
    var body: some View {
        HStack(alignment: .top, spacing: CGFloat(3)) {
            VStack(alignment: .leading, spacing: CGFloat(3)) {
                Text(skylink.filename).font(.headline)
                Text("Uploaded:" + skylink.timestamp.timeAgo()).font(.subheadline).foregroundColor(.gray)
            }
            .onTapGesture {
                self.showSafari = true
            }
            Spacer()
            Button(action: {
                print("Button action")
                let pb = UIPasteboard.general
                pb.string = "https://siasky.net/\(self.skylink.link)"

            }) {
                Text("Copy")
                    .foregroundColor(.green)
                    .padding(6.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10.0)
                            .stroke(lineWidth: 1.0)
                            .foregroundColor(.green)
                    )
            }
        }
        .sheet(isPresented: $showSafari) {
            SafariView(url: URL(string: "https://siasky.net/\(self.skylink.link)")!)
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
            .navigationBarTitle(Text("Skylinks"))
            .navigationBarItems(leading: Button(action: fetch) {
                Text("Reload")
                    .font(.title)
                    .foregroundColor(.green)
            }, trailing:
            NavigationLink(destination: SkylinksView()) {
                Text("Portals")
            }
            )
        }
    }

    func portals() {
    }

    func fetch() {
        skylinks = Manager.load()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SkylinksView()
    }
}
