//
//  Skynet.swift
//  Skynet
//
//  Created by Wojciech Mandrysz on 29/02/2020.
//  Copyright © 2020 Wojciech Mandrysz. All rights reserved.
//

import Foundation
import Alamofire

class Skynet {
    let portal = "https://siasky.net/"
    let uploadPath = "skynet/skyfile/"
    
    func upload(data: Data, filename: String? = nil, callback: @escaping (Bool, String) -> ()) -> Bool {
        let uuid = UUID().uuidString
        guard let url = URL(string: portal + uploadPath + uuid) else {
            return false
        }

        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(data, withName: "file", fileName: filename ?? uuid)
        }, to: url)
            .uploadProgress { progress in
                print("Upload Progress: \(progress.fractionCompleted)")
            }.responseJSON { (response) in
                debugPrint(response)
                switch response.result {
                case .success(let JSON):
                    print("Success with JSON: \(JSON)")

                    let response = JSON as! NSDictionary

                    //example if there is an id
                    if let skylink = response["skylink"] as? String {
                        print(skylink)
                        callback(true, skylink)
//                        self.download(skylink: skylink)
                    }
                    else {
                        callback(false, "No skylink in JSON")
                    }
                    
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    callback(false, "Failure")
                }
                
            }
        
        return true
    }
    func download(skylink: String) -> Void {
        AF.download(portal + skylink).responseData { response in
            debugPrint(response)
            if let data = response.value {
//                let image = UIImage(data: data)
            }
        }
    }
}
