//
//  Copyright © 2018 zalando.de. All rights reserved.
//

import Foundation

/// Data structure representing eventual token repsone from token server.
public struct OAuth2AccessToken: Codable {

    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
    }

}
