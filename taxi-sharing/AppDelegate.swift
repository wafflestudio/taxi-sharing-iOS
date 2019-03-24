//
//  AppDelegate.swift
//  taxi-sharing
//
//  Created by 오승열 on 12/02/2019.
//  Copyright © 2019 CroonSSS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Use Firebase library to configure 
        FirebaseApp.configure()
        
        let db = Firestore.firestore()
        // [END default_firestore]
        print(db) // silence warning
        
        // Enable IQKeyboardManagerSwift
        IQKeyboardManager.shared.enable = true
        
        // Sets the initial view controller based on the user's authentication
        if Auth.auth().currentUser != nil {
            FirestoreManager().checkUser(uid: Auth.auth().currentUser?.uid) {(success) in
                if success == true {
                    FirestoreManager().updateLogin(uid: Auth.auth().currentUser?.uid)
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
                    self.window?.rootViewController = initialViewController
                    self.window?.makeKeyAndVisible()
                } else if success == false {
                    FirestoreManager().checkDriver(uid: Auth.auth().currentUser?.uid) {(success) in
                        if success == true {
                            FirestoreManager().updateDriverLogin(uid: Auth.auth().currentUser?.uid)
                            self.window = UIWindow(frame: UIScreen.main.bounds)
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let initialViewController = storyboard.instantiateViewController(withIdentifier: "DriverMainViewController")
                            self.window?.rootViewController = initialViewController
                            self.window?.makeKeyAndVisible()
                        } else {
                            self.window = UIWindow(frame: UIScreen.main.bounds)
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let initialViewController = storyboard.instantiateViewController(withIdentifier: "UserDistinguishViewController")
                            self.window?.rootViewController = initialViewController
                            self.window?.makeKeyAndVisible()
                        }
                    }
                    
                }
            }
        } else {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "UserDistinguishViewController")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        KOSession.handleDidEnterBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        KOSession.handleDidBecomeActive()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: Kakao Login
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        
        if KOSession.handleOpen(url) {
            return true
        }
        return false
    }
}

