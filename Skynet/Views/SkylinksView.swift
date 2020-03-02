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
        .onLongPressGesture {
            withAnimation {
                self.copied.toggle()
            }
            Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { _ in
                withAnimation {
                    self.copied.toggle()
                }
            }

            print("Button action")
            let pb = UIPasteboard.general
            pb.string = Manager.currentPortal.downloadURL(skylink: self.skylink.link).absoluteString
        }
        .sheet(isPresented: $showSafari) {
            SafariView(url: Manager.currentPortal.downloadURL(skylink: self.skylink.link))
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
            NavigationLink(destination: PortalsView()) {
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
