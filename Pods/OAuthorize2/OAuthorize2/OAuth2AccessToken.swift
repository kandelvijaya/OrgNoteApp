//
//  Copyright © 2018 zalando.de. All rights reserved.
//

import Foundation

/// Data structure representing eventual token repsone from token server.
public struct OAuth2AccessToken: Codable {

    public let accessToken: String
    public let tokenType: String
    public let expiresIn: Int
    public let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
    }

}
