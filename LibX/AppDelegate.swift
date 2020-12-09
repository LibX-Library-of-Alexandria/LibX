//
//  AppDelegate.swift
//  LibX
//
//  Created by Aidan Furey on 11/22/20.
//

import UIKit
import Parse

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    //Import file
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        var backgroundTaskId = UIApplication.shared.beginBackgroundTask (withName: "Import libx file")
        
        // handle the file here
        print("In AppDelegate")
        //Verify url's extension is libx
        guard url.pathExtension == "libx" else { return false }

        //Import data using static method
        ListsViewController.importData(from: url)
        UIApplication.shared.endBackgroundTask(backgroundTaskId)
        backgroundTaskId = UIBackgroundTaskIdentifier.invalid
        return true
    }
    //Import file

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let parseConfig = ParseClientConfiguration {
                            $0.applicationId = "Mb8owwC4ovinbdnyIzvY3CoZyYETghlUn5JF2Pp9"
                            $0.clientKey = "vFM5pCoNycUlDvt91EpnA4TD1URkj8bp1XaHAghH"
                            $0.server = "https://parseapi.back4app.com"
                    }
                Parse.initialize(with: parseConfig)
        return true
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

