//
//  OrgFileMock.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 01.06.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import Kekka

protocol OrgFileServiceProtocol {

    func fetchWorkLog() -> Future<Result<OrgFile>>

}



struct Mock {

    enum OrgFileServiceError: Error {
        case fileNotFound
        case fileDoesnotContainProperStringContent
        case unknown
    }

    struct OrgFileService: OrgFileServiceProtocol {

        func fetchWorkLog() -> Future<Result<OrgFile>> {
            return KPromise<Result<OrgFile>>({ (aComplation) in
                guard let url = Bundle.main.url(forResource: "WL", withExtension: "org"),
                    let buffer = try? String(contentsOf: url),
                    let orgFile = OrgParser.parse(buffer) else {
                        aComplation?(Result.failure(error: OrgFileServiceError.unknown))
                        return 
                }
                aComplation?(.success(value: orgFile))
            })
        }

    }

}
