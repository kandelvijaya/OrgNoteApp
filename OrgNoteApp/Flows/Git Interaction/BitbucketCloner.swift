//
//  BitbucketCloner.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 06.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation
import Kekka
import ObjectiveGit

struct BitbucketClone {

    private let accessToken: String

    init(with accessToken: String) {
        self.accessToken = accessToken
    }

    enum CloneError: Error {
        case remoteNotFound
        case cloneAccessDenied
        case couldntWriteToLocalFileSystem
        case couldntLocateUserDocumentsDirectory
        case unknown(with: Error)
        case repoModelHasNoValidURL(BitbucketRepository.Value)
    }

    func clone(_ repoModel: BitbucketRepository.Value) -> Result<UserSelectedRepository> {
        return remoteToeknizedURL(for: repoModel).flatMap(targetDirectoryURLToClone).flatMap(clone).map { item in
            return UserSelectedRepository(model: repoModel, remoteURL: item.remote, folderName: item.local.lastPathComponent)
        }
    }

    private func clone(remote: URL, to local: URL) -> Result<(remote: URL, local: URL)> {
        guard FileManager.default.fileExists(atPath: local.path) else {
            let tryCreating = doTry{ try FileManager.default.createDirectory(at: local, withIntermediateDirectories: false, attributes: nil) }
            let tryCloning = { doTry { try GTRepository.clone(from: remote, toWorkingDirectory: local, options: [GTRepositoryCloneOptionsTransportFlags: true], transferProgressBlock: nil) } }

            let cloningResult = tryCreating.flatMap { _ in
                return tryCloning()
                }.map { _ in
                    return (remote: remote, local: local)
            }
            return cloningResult
        }

        return .success(value: (remote: remote, local: local))
    }

    private func remoteToeknizedURL(for repoModel: BitbucketRepository.Value) -> Result<URL> {
        guard let repoURL = repoModel.links.clone.first?.href, let host = repoURL.host else {
            return CloneError.repoModelHasNoValidURL(repoModel).result()
        }

        let tokenBase = URL(string: "https://x-token-auth:\(accessToken)@\(host)")!
        let url = tokenBase.appendingPathComponent(repoURL.path)
        return .success(value: url)
    }

    private func targetDirectoryURLToClone(for remoteURL: URL) -> Result<(remote: URL, local: URL)> {
        guard let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            return CloneError.couldntLocateUserDocumentsDirectory.result()
        }

        let workingDir = documentsDir.appendingPathComponent(remoteURL.lastPathComponent, isDirectory: true)
        let value = (remote: remoteURL, local: workingDir)
        return .success(value: value)
    }

}
