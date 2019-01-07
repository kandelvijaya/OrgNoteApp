//
//  AuthorizeController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 04.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit
import OAuthorize2

final class AuthorizeController: UIViewController, StoryboardAwaker {
    
    @IBOutlet weak var authorizeButton: UIButton!

    @IBAction func authorizeUser(_ sender: Any) {
        let oauth = BitbucketOauth2.shared
        oauth.askForAuthorizationCodeIfNeeded()
    }

    static func create() -> AuthorizeController {
        let controller = created
        controller.title = "Authorize with Bitbucket"
        return controller
    }



}

final class BitbucketOauth2: OAuth2 {

    static let shared = BitbucketOauth2()
    private init() {}

    var config: OAuth2Config {
        let clientKey = "wkEKsLe7jVmz7gVX3E"
        let clientSecret = "2burgLy9BRTpsmdZbNKCAR5ZnUwZZ2jE"
        let redirectURI = URL(string: "orgnoteapp://authrorized")!
        return BitbucketOauth2Config.config(withId: clientKey, clientSecret: clientSecret, scopes: [], redirectURI: redirectURI)
    }


}
