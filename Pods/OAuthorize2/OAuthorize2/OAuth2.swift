//
//  Copyright © 2018 zalando.de. All rights reserved.
//

import Foundation
import UIKit
import Kekka

/// Interface for any types that want to perform OAuth2 with the REST API
public protocol OAuth2: class {

    /// OAuth2 required config file
    var config: OAuth2Config { get }

    /// Specify concrete implementation of Access Token Storage
    /// It is preferred to use `Keychain`.
    /// By Default, OAuth2 will store and retrieve in file
    var accessTokenStorageService: OAuth2AccessTokenStorageProtocol { get }

    /// Specify networking API to use
    var accessTokenNetworkService: OAuth2NetworkServiceProtocol { get }

    /// checks if initial authroization is required or not
    /// Default implementation is to look for stored access token availability
    func isAuthorizationRequired() -> Bool

    /// Asks the Authorization server for authorization code
    /// The AuthServer is opened in the external web browser and
    /// it can ask the resource owner for authentication and verification
    /// before it calls on the redirectURI with code parameter.
    /// STEP 1
    func askForAuthorizationCodeIfNeeded()

    /// Asks the token server with the authorization code obtained from
    /// the `askForAuthorizationCode()` method.
    /// When successful, this will return AccessToken object
    /// STEP 2
    func askForAccessToken(with authorizationCode: String) -> Future<Result<OAuth2AccessToken>>
    func askForAccessToken(with authorizationCode: String, onCompletion: @escaping ((OAuth2AccessToken?) -> Void))


    /// Take a mutable request and inserts access token when possible
    /// - When the access token is expired; it should perform `refeshToken` and verifies the request
    /// - When the access token is not found; it should perform `askForAuthorization` and returns nil immediately
    ///   It is the client that has to call `verifiedRequest` after the authorization succeeds.
    /// - STEP 3
    func verifyRequest(from request: NSMutableURLRequest) -> Result<NSMutableURLRequest>

    /// Aks for accessToken with the use of previously stored refresh token
    func refreshAccessToken() -> Future<Result<OAuth2AccessToken>>
    func refreshAccessToken(_ onCompletion: @escaping ((OAuth2AccessToken?) -> Void))

    // MARK:- utility
    func extractAuthCode(from url: URL) -> String?

}


public extension OAuth2 {

    public var accessTokenStorageService: OAuth2AccessTokenStorageProtocol {
        return OAuth2FileBasedAccessTokenStorageService()
    }

    public var accessTokenNetworkService: OAuth2NetworkServiceProtocol {
        return OAuthNetworkService()
    }

    public func isAuthorizationRequired() -> Bool {
        return accessTokenStorageService.retrieve(tokenFor: config) == nil
    }

    public func askForAuthorizationCodeIfNeeded() {
        guard isAuthorizationRequired() else { return }
        let query = "?client_id=\(config.clientId)&redirect_uri=\(config.redirectURI.absoluteString)&response_type=code&scope=\(config.scopesString)"
        let fullURL = config.authServer.absoluteString + query
        guard let url = URL(string: fullURL) else {
            print("malformed url \(config.authServer)")
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    public func askForAccessToken(with authorizationCode: String) -> Future<Result<OAuth2AccessToken>> {
        let request = tokenServerRequest(with: authorizationCode)
        return fetchStoreAccessToken(with: request)
    }

    func askForAccessToken(with authorizationCode: String, onCompletion: @escaping ((OAuth2AccessToken?) -> Void)) {
        askForAccessToken(with: authorizationCode).then { res in
            if case let .success(v) = res {
                onCompletion(v)
            } else {
                onCompletion(nil)
            }
        }.execute()
    }

    private func fetchStoreAccessToken(with request: URLRequest) -> Future<Result<OAuth2AccessToken>> {
        let future = accessTokenNetworkService.post(withRequest: request)
        return future.then { response in
            switch response {
            case let .success(token):
                self.accessTokenStorageService.store(token: token, for: self.config)
                return response
            case .failure(_):
                return response
            }
        }
    }

    public func verifyRequest(from request: NSMutableURLRequest) -> Result<NSMutableURLRequest> {
        guard let accessToken = accessTokenStorageService.retrieve(tokenFor: config) else {
            return .failure(OAuth2Error.accessTokenNotFound)
        }
        let bearerToken = "Bearer \(accessToken.accessToken)"
        request.addValue(bearerToken, forHTTPHeaderField: "Authorization")
        return .success(request)
    }

    // MARK:- Private helper functions

    /// checks if the url contains authorization code
    public func extractAuthCode(from url: URL) -> String? {
        if var q = url.query {
            q.removeSubrange(q.range(of: "code=")!)
            return q
        } else if let range = url.absoluteString.range(of: "(?<=\\?code=).*", options: .regularExpression, range: nil, locale: nil) {
            let str = url.absoluteString[range]
            let code = str.split(separator: "?").first.map(String.init) ?? String(str)
            return code
        } else {
            return nil
        }
    }

    private func tokenServerRequest(with authorizationCode: String) -> URLRequest {
        var bodyData = "code=\(authorizationCode)&client_id=\(config.clientId)&redirect_uri=\(config.redirectURI.absoluteString)&grant_type=\(config.grantType)"
        if let secret = config.clientSecret {
            bodyData += "&client_secret=\(secret)"
        }
        return canonicalRequest(with: bodyData)
    }

    private func canonicalRequest(with bodyData: String) -> URLRequest {
        let mutableRequest = NSMutableURLRequest(url: config.tokenServer)
        mutableRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        mutableRequest.httpMethod = "POST"
        mutableRequest.httpBody = bodyData.data(using: .utf8)!
        return mutableRequest as URLRequest
    }

    private func tokenServerRefreshTokenRequest(with refreshToken: String) -> URLRequest {
        var bodyData = "client_id=\(config.clientId)&grant_type=refresh_token&refresh_token=\(refreshToken)"
        if let secret = config.clientSecret {
            bodyData += "&client_secret=\(secret)"
        }
        return canonicalRequest(with: bodyData)
    }

    public func refreshAccessToken() -> Future<Result<OAuth2AccessToken>> {
        guard let refreshToken = accessTokenStorageService.retrieve(tokenFor: config)?.refreshToken else {
            return Future<Result<OAuth2AccessToken>> { $0?(.failure(OAuth2Error.refreshTokenNotFound)) }
        }
        let request = tokenServerRefreshTokenRequest(with: refreshToken)
        return fetchStoreAccessToken(with: request)
    }

    func refreshAccessToken(_ onCompletion: @escaping ((OAuth2AccessToken?) -> Void)) {
        refreshAccessToken().then { res in
            if case let .success(v) = res {
                onCompletion(v)
            } else {
                onCompletion(nil)
            }
        }.execute()
    }

}
