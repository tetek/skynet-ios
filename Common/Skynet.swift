//
//  Skynet.swift
//  Skynet
//
//  Created by Wojciech Mandrysz on 29/02/2020.
//  Copyright © 2020 Wojciech Mandrysz. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

class Skynet : NSObject {
    
    let portal = "https://siasky.net/"
    let uploadPath = "skynet/skyfile/"
    var buffer = NSMutableData()
    var completion: (() -> Void)?
    var newsession: URLSession?
    
    func resumeSession(id: String, completionHandler: @escaping () -> Void) {
        completion = completionHandler
        let configuration = URLSessionConfiguration.background(withIdentifier: id)
        configuration.timeoutIntervalForRequest = 60
        configuration.sharedContainerIdentifier = "group.tech.sia.skynet"
        newsession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
    }
    var session: URLSession {
        get {
            let configuration = URLSessionConfiguration.background(withIdentifier: "tech.sia.skynet.background." + UUID().uuidString)
            configuration.timeoutIntervalForRequest = 60
            configuration.sharedContainerIdentifier = "group.tech.sia.skynet"
            configuration.sessionSendsLaunchEvents = true
            configuration.isDiscretionary = false
            return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        }
    }


    func upload(data: Data, filename: String? = nil, callback: @escaping (Bool, String) -> ()) -> Bool {
        let uuid = UUID().uuidString
        guard let url = URL(string: portal + uploadPath + uuid) else {
            return false
        }
        let (fileURL, contentType) = tempFile(data: data, filename: filename)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(filename ?? uuid, forHTTPHeaderField: "filename")
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let task = session.uploadTask(with: request, fromFile: fileURL)
        task.resume()
        return true
        

    }
    func tempFile(data: Data, filename: String?) -> (URL, String) {
        let multipartFormData = MultipartFormData(fileManager: .default, boundary: "boundry")
        multipartFormData.append(data, withName: "file", fileName: filename ?? "No name")
        let fileManager = FileManager.default
        let tempDirectoryURL = fileManager.temporaryDirectory
        let directoryURL = tempDirectoryURL.appendingPathComponent("org.alamofire.manager/multipart.form.data")
        
        let fm = UUID().uuidString
        let fileURL = directoryURL.appendingPathComponent(fm)

        try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)

        do {
            try multipartFormData.writeEncodedData(to: fileURL)
        } catch {
            // Cleanup after attempted write if it fails.
            try? fileManager.removeItem(at: fileURL)
        }
        return (fileURL, multipartFormData.contentType)
    }
    
    func download(skylink: String) -> Void {
        AF.download(portal + skylink).responseData { response in
            debugPrint(response)
            if let data = response.value {
//                let image = UIImage(data: data)
            }
        }
    }
    
    func finito(skylink: String) {
        let content = UNMutableNotificationContent()
        content.title = "Skylink ready"
        content.subtitle = "In the clipboard"
        content.body = skylink
        
        // 2
//        let imageName = "applelogo"
//        guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
//
//        let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
//
//        content.attachments = [attachment]
//
        // 3
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "notification.id.01", content: content, trigger: trigger)
        
        // 4
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

extension Skynet : URLSessionTaskDelegate, URLSessionDataDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let json = try? JSONSerialization.jsonObject(with: buffer as Data, options: []) as? [String : Any]
        debugPrint(json)
//        debugPrint(task.response)
//        debugPrint(task.response?.suggestedFilename)
//        debugPrint(task.response as? HTTPURLResponse)
        debugPrint(task.originalRequest?.allHTTPHeaderFields)

        if let skylink =  json?["skylink"] as? String {
            let pasteboard = UIPasteboard.general
            pasteboard.string = skylink
            var n = ""
            if let name = task.originalRequest?.allHTTPHeaderFields?["filename"] {
                n = name
            }
            DispatchQueue.main.async {
                Manager.add(skylink: Skylink(link: skylink, filename: n))
                self.finito(skylink: skylink)
            }
        }
    }
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        session.invalidateAndCancel()
         DispatchQueue.main.async {
            self.completion?()
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)
    }
    
}
