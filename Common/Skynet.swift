//
//  Skynet.swift
//  Skynet
//
//  Created by Wojciech Mandrysz on 29/02/2020.
//  Copyright © 2020 Wojciech Mandrysz. All rights reserved.
//

import Alamofire
import Foundation
import UIKit

class Skynet: NSObject {
    let portal: Portal

    init(portal: Portal) {
        self.portal = portal
    }

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
        let configuration = URLSessionConfiguration.background(withIdentifier: "tech.sia.skynet.background." + UUID().uuidString)
        configuration.timeoutIntervalForRequest = 60
        configuration.sharedContainerIdentifier = "group.tech.sia.skynet"
        configuration.sessionSendsLaunchEvents = true
        configuration.isDiscretionary = false
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    func uploadInBackground(data: Data, filename: String? = nil) {
        let url = portal.newUploadURL()

        let (fileURL, contentType) = tempFile(data: data, filename: filename)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(filename ?? "No-name", forHTTPHeaderField: "filename")
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")

        let task = session.uploadTask(with: request, fromFile: fileURL)
        task.resume()
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

    //Upload Many files at once - for later
//    func uploadInBackground(datas: [Data], filenames: [String]? = nil) {
//        let url = portal.newUploadURL()
//
//        let (fileURL, contentType) = tempFile(datas: datas, filenames: filenames)
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("dir-from-ios", forHTTPHeaderField: "filename")
//        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
//
//        let task = session.uploadTask(with: request, fromFile: fileURL)
//        task.resume()
//    }
//
//    func tempFile(datas: [Data], filenames: [String]?) -> (URL, String) {
//        let multipartFormData = MultipartFormData(fileManager: .default, boundary: "boundry")
//        for i in 0 ... datas.count {
//            let filename: String = filenames?[i] ?? "No name"
//            multipartFormData.append(datas[i], withName: "file", fileName: filename)
//        }
////        for data in datas {
////            multipartFormData.append(data, withName: "file", fileName: filename ?? "No name")
////        }
//
//        let fileManager = FileManager.default
//        let tempDirectoryURL = fileManager.temporaryDirectory
//        let directoryURL = tempDirectoryURL.appendingPathComponent("org.alamofire.manager/multipart.form.data")
//
//        let fm = UUID().uuidString
//        let fileURL = directoryURL.appendingPathComponent(fm)
//
//        try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
//
//        do {
//            try multipartFormData.writeEncodedData(to: fileURL)
//        } catch {
//            // Cleanup after attempted write if it fails.
//            try? fileManager.removeItem(at: fileURL)
//        }
//        return (fileURL, multipartFormData.contentType)
//    }

    func finito(skylink: String) {
        // Clipboard
        let pasteboard = UIPasteboard.general
        pasteboard.string = skylink

        // Notification
        let content = UNMutableNotificationContent()
//        content.title = "Skynet"
        content.subtitle = "Last uploaded skylink in the clipboard"

        let imageName = "AppIcon"
        if let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") {
            let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
            content.attachments = [attachment]
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "notification.id.01", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

extension Skynet: URLSessionTaskDelegate, URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let json = try? JSONSerialization.jsonObject(with: buffer as Data, options: []) as? [String: Any]

        if let skylink = json?["skylink"] as? String {
            if let name = task.originalRequest?.allHTTPHeaderFields?["filename"] {
                DispatchQueue.main.async {
                    Manager.shared.add(skylink: Skylink(link: skylink, filename: name, timestamp: Date(), portalName: self.portal.name))
                    self.finito(skylink: skylink)
                }
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
