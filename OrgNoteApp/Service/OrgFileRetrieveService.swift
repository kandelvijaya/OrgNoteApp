//
//  OrgFileRetrieveService.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 02.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import Kekka

protocol OrgFileRetrieveServiceProtocol {
    func retrieveOrgFile(for url: URL) -> Future<Result<OrgFile>>
    func saveOrgFile(for url: URL) -> Future<Result<Void>>
}


final class OrgFileRetrieveService: OrgFileRetrieveServiceProtocol {

    private let orgParser: (String) -> OrgFile?
    private let networkingService: NetworkServiceProtocol

    init(orgParser: @escaping (String) -> OrgFile?, networkService: NetworkServiceProtocol = NetworkService()) {
        self.orgParser = orgParser
        self.networkingService = networkService
    }

    enum ServiceError: String, Error {
        case localFileDoesnotExist
        case localFileIsNotOrgFile
        case localFileRetrivalError
    }

    func retrieveOrgFile(for url: URL) -> Future<Result<OrgFile>> {
        if url.isFileURL {
            let filePath = url.path
            guard FileManager.default.fileExists(atPath: filePath) else {
                return Result.failure(error: ServiceError.localFileDoesnotExist) |> Future.init
            }

            let parsed = doTry{ try String(contentsOfFile: filePath) }.flatMap { str -> Result<OrgFile> in
                guard let orgFile = orgParser(str) else {
                    return ServiceError.localFileIsNotOrgFile |> Result.failure
                }
                return orgFile |> Result.success
            }
            return parsed |> Future.init

        } else {
            return networkingService.getOrgFile(url)
        }
    }

    func saveOrgFile(for url: URL) -> Future<Result<Void>> {
        enum SomeError: Error {
            case some
        }
        // No implementation for now
        return SomeError.some |> Result.failure |> Future.init
    }

}
