//
//  AddPortalView.swift
//  Skynet
//
//  Created by Wojciech Mandrysz on 05/03/2020.
//  Copyright © 2020 Wojciech Mandrysz. All rights reserved.
//

import Foundation
import SwiftUI

struct AddPortalView: View {
    @State private var name: String = ""
    @State private var host: String = ""
    @State private var downloadPath: String = ""
    @State private var uploadPath: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State var alert = false
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Info"), footer: Text("Make sure to fill this correctly. See an example in parentheses")) {
                    TextField("Name (Sia Skynet)", text: $name)
                    TextField("Host (https://siasky.net/)", text: $host).autocapitalization(.none).disableAutocorrection(true)
                    TextField("Download path (skynet/skyfile)", text: $downloadPath).autocapitalization(.none).disableAutocorrection(true)
                    TextField("Upload path ()", text: $uploadPath).autocapitalization(.none).disableAutocorrection(true)
                }
                HStack {
                    Spacer()
                    Image("built", bundle: Bundle.main).resizable().frame(width: 79.0, height: 70.0)
                }
            }
            
        }
        .alert(isPresented: $alert) {
            Alert(title: Text("Provided data seems invalid"), message: Text("Make sure you provided protocol with the host name"), dismissButton: .default(Text("Got it!")))
        }
        .navigationBarTitle(Text("Add a portal"))
        .navigationBarItems(trailing:
            Button(action: {
                print("save")

                if self.name.count > 2 && self.host.count > 7 && (self.host.hasPrefix("http://") || self.host.hasPrefix("https://")) {
                    let p = Portal(name: self.name, host: self.host, uploadPath: self.uploadPath, downloadPath: self.downloadPath)
                    MyPortals.shared.add(portal: p)
//                    self.showView = false
                    self.presentationMode.wrappedValue.dismiss()
                } else {
                    self.alert = true
                }

            }, label: {
                Text("Save")
            })
        )
    }
}
