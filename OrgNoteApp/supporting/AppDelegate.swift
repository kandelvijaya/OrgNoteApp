//
//  AppDelegate.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 13.05.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import UIKit
import Instabug

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // TODO:- secure key with git-crypt possibly
        Instabug.start(withToken: "1654e29831cbf5d22d2c5f6a7a6b19e8", invocationEvents: [.shake, .screenshot])
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let authorizationCode = BitbucketOauth2.shared.extractAuthCode(from: url) {
            BitbucketOauth2.shared.askForAccessToken(with: authorizationCode).then { item in
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: userDidReceiveAccessTokenNotification, object: self)
                }
            }.execute()
        }
        return true 
    }

}


let userDidReceiveAccessTokenNotification = NSNotification.Name(rawValue: "userDidReceiveAccessToken")
