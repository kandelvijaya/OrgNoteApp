//
//  OAuth2Error.swift
//  OAuthorize2
//
//  Created by Vijaya Prakash Kandel on 14.01.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation

public enum OAuth2Error: Error {

    case refreshTokenNotFound
    case accessTokenNotFound
    case unknownNetworkError
    case networkFailed(with: Error)
    case dataConversionFailed(with: Error)

}
