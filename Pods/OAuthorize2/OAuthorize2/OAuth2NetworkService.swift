//
//  Copyright © 2018 zalando.de. All rights reserved.
//

import Foundation
import Kekka

/// Conforming type can participate in network layer of OAuth2
public protocol OAuth2NetworkServiceProtocol {

    func post(withRequest urlRequest: URLRequest) -> Future<Result<OAuth2AccessToken>>

}


struct OAuthNetworkService: OAuth2NetworkServiceProtocol {

    enum NetworkError: Error {
        case unknown
    }

    public func post(withRequest urlRequest: URLRequest) -> Future<Result<OAuth2AccessToken>> {
        return Future { aCompletion in
            let session = URLSession(configuration: .default)
            session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                if error != nil {
                    aCompletion?(.failure(error: error!))
                } else if data != nil {
                    guard let token = try? JSONDecoder().decode(OAuth2AccessToken.self, from: data!) else {
                        aCompletion?(.failure(error: NetworkError.unknown))
                        return
                    }
                    aCompletion?(.success(value: token))
                } else {
                    aCompletion?(.failure(error: NetworkError.unknown))
                }

            }).resume()
        }
    }

}
