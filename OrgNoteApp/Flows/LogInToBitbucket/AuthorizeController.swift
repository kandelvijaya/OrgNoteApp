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

    private var onDone: ClosedBlock!

    static func created(_ onAuthorized: @escaping ClosedBlock) -> AuthorizeController {
        let controller = created
        controller.onDone = onAuthorized
        controller.title = "Authorize to proceed"
        return controller
    }
    
    @IBOutlet weak var authorizeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        authorizeButton.tintColor = Theme.blueish.buttonTint
    }

    @IBAction func authorizeUser(_ sender: Any) {
        let oauth = BitbucketOauth2.shared
        if oauth.isAuthorizationRequired() {
            oauth.askForAuthorizationCodeIfNeeded()
        } else {
            onDone()
        }
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

    func repoUrlRepacingNewAccessToken(_ url: URL) -> URL {
        if let token = self.accessTokenStorageService.retrieve(tokenFor: self.config)?.accessToken,
            let compoments = NSURLComponents(url: url, resolvingAgainstBaseURL: false) {
            compoments.password = token
            return compoments.url ?? url
        } else {
            return url
        }
    }


}
