//
//  AppDelegate.swift
//  Skynet
//
//  Created by Wojciech Mandrysz on 29/02/2020.
//  Copyright © 2020 Wojciech Mandrysz. All rights reserved.
//

import UIKit
import Alamofire
var skynet: Skynet?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        Skynet().upload(data: "Hello elo".data(using: .utf8)!) { (s, sk) in
//            print("eki")
//        }
//        Manager.add(skylink: Skylink(link: "HEJA", filename: "kurwo"))        
        UNUserNotificationCenter.current().requestAuthorization(options: UNAuthorizationOptions.alert) { (success, error) in
            
        }
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        skynet = Skynet(portal: Manager.currentPortal)
        skynet?.resumeSession(id: identifier, completionHandler: completionHandler)
//        DispatchQueue.main.async {
////           completionHandler()
//        }
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

