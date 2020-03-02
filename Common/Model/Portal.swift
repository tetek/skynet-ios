//
//  Portal.swift
//  Skynet
//
//  Created by Wojciech Mandrysz on 01/03/2020.
//  Copyright © 2020 Wojciech Mandrysz. All rights reserved.
//

import Foundation
import SwiftUI

struct Portal: Identifiable {
    /// unique id
    var id: String = UUID().uuidString
    let host: String // = "https://siasky.net/"
    let uploadPath: String  //=/// "skynet/skyfile/"
    let downloadPath: String
    let name: String
    
    /// Init
    init(name: String, host: String, uploadPath: String, downloadPath: String = "") {
        self.name = name
        self.host = host
        self.uploadPath = uploadPath
        self.downloadPath = downloadPath
    }
}
struct PortalView: View {
   
    /// post
    let portal: Portal
    
    /// body
    var body: some View {
        
        /// main vertical stack view - contains upper stackview and image
        
//        VStack(alignment: HorizontalAlignment.leading, spacing: CGFloat(10)) {
            
            // Upper Stackview - Contains Horizontal stack and post content
//            VStack(alignment: HorizontalAlignment.leading) {
//                HStack(spacing: CGFloat(10)) {
                    VStack(alignment: .leading, spacing: CGFloat(3)) {
                        // name
                        Text(portal.name).font(.headline)
                        
                        
//                    }
//                }
                                
//            }
        }
//        .padding(.top, 5)
    }
}
