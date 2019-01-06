//
//  BitbucketOAuth2Config.swift
//  OAuthorize2
//
//  Created by Vijaya Prakash Kandel on 05.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation

public struct BitbucketOauth2Config {

    public static let authServer = URL(string: "https://bitbucket.org/site/oauth2/authorize")!
    public static let tokenServer = URL(string: "https://bitbucket.org/site/oauth2/access_token")!

    public static func config(withId clientId: String, clientSecret: String, scopes: [String], redirectURI: URL) -> OAuth2Config{
        return OAuth2Config(clientId: clientId, scopes: scopes, authServer: authServer, tokenServer: tokenServer, redirectURI: redirectURI, clientSecret: clientSecret)
    }

}
