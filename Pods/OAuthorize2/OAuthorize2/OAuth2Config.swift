//
//  Copyright © 2018 zalando.de. All rights reserved.
//

import Foundation

/// A config struct that holds essential information
/// required to make successful OAuth2 synchronization.
public struct OAuth2Config: Codable {

    /// `client_id` is generated during registration of the client app
    public let clientId: String

    /// Refer to the provided scope url endpoint
    /// i.e. google developer
    public let scopes: [String]

    /// url for authorizationServer without the parameter fields
    public let authServer: URL

    /// url for the tokenServer without the parameter fields
    public let tokenServer: URL

    /// generated during the registration of the client app
    /// for iOS apps, navigate to info.plist and set the custom url scheme
    /// URLTypes .. URL Schemes and add a entry with this exact redirectURI
    /// When the app's custom scheme doesnot match the redirectURI,
    /// most authorization services will throw a error after authenticating owner
    public let redirectURI: URL

    var scopesString: String {
        return scopes.joined(separator: " ").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }

    /// Unless specific otherwise this will be "authorization_code" in most cases
    public let grantType: String

}


public extension OAuth2Config {

    public init(clientId: String, scopes: [String], authServer: URL, tokenServer: URL, redirectURI: URL) {
        self.clientId = clientId
        self.scopes = scopes
        self.authServer = authServer
        self.tokenServer = tokenServer
        self.redirectURI = redirectURI
        self.grantType = "authorization_code"
    }

}
