//
//  NetworkService.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 25.11.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import Kekka
import UIKit

protocol NetworkServiceProtocol {
    func getOrgFile(_ path: URL) -> Future<Result<OrgFile>>
}


final class NetworkService: NetworkServiceProtocol {

    enum NetworkServiceError: Error {
        case error(Error)
        case emptyResourceFound
        case dataConversionFailed(String)
    }

    func getOrgFile(_ path: URL) -> Future<Result<OrgFile>> {
        return get(path).then { dataR -> Result<String> in
            return dataR.flatMap { data in
                if let str = String(data: data, encoding: .utf8) {
                    return Result<String>.success(str)
                } else {
                    return Result<String>.failure(NetworkServiceError.dataConversionFailed("File not in utf8 format"))
                }
            }
        }.then { stringR in
            return stringR.flatMap { str in
                if let orgFile = OrgParser.parse(str) {
                    return Result<OrgFile>.success(orgFile)
                } else {
                    return Result<OrgFile>.failure(NetworkServiceError.dataConversionFailed("File is a Org structured document"))
                }
            }
        }
    }

    private func get(_ path: URL) -> Future<Result<Data>> {
        return dataTask(URLRequest(url: path))
    }

    func dataTask(_ request: URLRequest) -> Future<Result<Data>> {
        return Future { aCompletion in
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if error != nil {
                    asyncOnMain{ aCompletion?(Result<Data>.failure(NetworkServiceError.error(error!))) }
                    return
                }

                if data == nil {
                    asyncOnMain{ aCompletion?(.failure(NetworkServiceError.emptyResourceFound)) }
                    return
                } else {
                    asyncOnMain{ aCompletion?(.success(data!)) }
                    return
                }
            }).resume()
        }
    }

}

