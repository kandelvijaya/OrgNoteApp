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

    public func post(withRequest urlRequest: URLRequest) -> Future<Result<OAuth2AccessToken>> {
        return Future { aCompletion in
            let session = URLSession(configuration: .default)
            session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                if let error = error {
                    asyncOnMain{ aCompletion?(.failure(OAuth2Error.networkFailed(with: error))) }
                } else if let _ = response as? HTTPURLResponse, let data = data {
                    do {
                        let token = try JSONDecoder().decode(OAuth2AccessToken.self, from: data)
                        asyncOnMain{ aCompletion?(.success(token)) }
                    } catch {
                        asyncOnMain{ aCompletion?(.failure(OAuth2Error.dataConversionFailed(with: error))) }
                    }

                } else {
                    asyncOnMain{ aCompletion?(.failure(OAuth2Error.unknownNetworkError)) }
                }

            }).resume()
        }
    }

}

func asyncOnMain(_ block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: block)
}
