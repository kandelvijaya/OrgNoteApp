//
//  BitbucketAPI.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 06.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation
import Kekka


protocol BitbucketAPIProtocol {
    func fetchUser() -> Future<Result<BitbucketUser>>
    func fetchRepositories() -> Future<Result<BitbucketRepository>>
}

final class BitbucketAPI: BitbucketAPIProtocol {

    enum APIError: Error {
        case couldntAddAceesTokenToRequest
        case requireRefreshAccessToken
    }

    let baseURL = URL(string: "https://bitbucket.org/api/2.0/")!
    lazy var user = self.baseURL.appendingPathComponent("user")

    private var userRequest: URLRequest? {
        let urlRequest = NSMutableURLRequest(url: user)
        urlRequest.httpMethod = "GET"
        return addAccessToken(to: urlRequest)
    }

    private func repoRequest(for user: BitbucketUser) -> URLRequest? {
        let url = baseURL.appendingPathComponent("repositories").appendingPathComponent(user.username)
        let request = addAccessToken(to: NSMutableURLRequest(url: url))
        return request
    }

    private var bUser: BitbucketUser?

    func fetchRepositories() -> Future<Result<BitbucketRepository>> {
        if let u = self.bUser {
            return fetch(for: repoRequest(for: u)).convert()
        } else {
            return fetchUser().bind { item -> Future<Result<Data>> in
                switch item {
                case let .success(v):
                    self.bUser = v
                    return self.fetch(for: self.repoRequest(for: v))
                case let .failure(e):
                    return Future(.failure(e))
                }
            }.convert()
        }
    }

    internal func fetchUser() -> Future<Result<BitbucketUser>> {
        return fetch(for: userRequest).convert()
    }

    private func fetch(for request: URLRequest?) -> Future<Result<Data>> {
        guard let request = request else {
            return Future(Result.failure(APIError.couldntAddAceesTokenToRequest))
        }
        return dataTaskByRefreshingAccessTokenIfNeeded(request)
    }

    func addAccessToken(to request: NSMutableURLRequest) -> URLRequest? {
        if let result = BitbucketOauth2.shared.verifyRequest(from: request).value {
            return result as URLRequest
        } else {
            return nil
        }
    }

    private func dataTaskByRefreshingAccessTokenIfNeeded(_ request: URLRequest) -> Future<Result<Data>> {
        return dataTask(request).bind { item in
            if let e = item.error, areEqual(e, APIError.requireRefreshAccessToken) {
                let eventual = BitbucketOauth2.shared.refreshAccessToken().bind { accToken -> Future<Result<Data>> in
                    switch accToken {
                    case .success:
                        return self.dataTask(request)
                    case let .failure(e):
                        return Future(.failure(e))
                    }
                }
                return eventual
            }
            return Future(item)
        }
    }

    private func dataTask(_ request: URLRequest) -> Future<Result<Data>> {
        return NetworkService().dataTask(request).then { item  in
            return item.flatMap { value -> Result<Data> in
                if let _ = doTry({ try JSONDecoder().decode(RefreshAccessTokenModel.self, from: value) }).value {
                    return Result<Data>.failure(APIError.requireRefreshAccessToken)
                } else {
                    // is not asking for access token refresh. must be other value
                    return Result<Data>.success(value)
                }
            }
        }
    }
}


extension Future where T == Result<Data>  {

    func convert<T:Codable>() -> Future<Result<T>> {
        return self.then { item in
            return item.flatMap { thisItem -> Result<T> in
                do {
                    let item =  try JSONDecoder().decode(T.self, from: thisItem)
                    return .success(item)
                } catch {
                    print(try! JSONSerialization.jsonObject(with: thisItem, options: []))
                    return .failure(error)
                }
            }
        }
    }
}
