//
//  BitbucketGitInteraction.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 07.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation
import ObjectiveGit
import Kekka

enum Affirmitive {
    case affirm
}

enum GitInteractionError: Error {
    case workingDirectoryIsClean_nothingToAdd
    case workingDirectoryIsClean_nothingChanged_nothingToCommit
    case nothingChanged_nothingToCommit
    case remoteDoesNotExist
}


struct Git {

    let repoInfo: UserSelectedRepository

    func add(_ file: String) -> Result<Affirmitive> {
        do {
            let repo = try GTRepository(url: self.repoInfo.clonedURL)
            if repo.isWorkingDirectoryClean {
                return .success(value: .affirm)
            }
            let index = try repo.index()
            try index.addFile(file)
            try index.write()
            return .success(value: .affirm)
        } catch {
            return .failure(error: error)
        }
    }

    func addAll() -> Result<Affirmitive> {
        do {
            let repo = try GTRepository(url: self.repoInfo.clonedURL)
            if repo.isWorkingDirectoryClean {
                return .success(value: .affirm)
            }
            let index = try repo.index()
            try index.addAll()
            try index.write()
            return .success(value: .affirm)
        } catch {
            return .failure(error: error)
        }
    }

    func commit(with message: String) -> Result<Affirmitive> {
        do {
            let repo = try GTRepository(url: self.repoInfo.clonedURL)
            if repo.isWorkingDirectoryClean {
                return .failure(error: GitInteractionError.workingDirectoryIsClean_nothingChanged_nothingToCommit)
            }
            let index = try repo.index()
            let currentBranch = try repo.currentBranch()
            let currentCommit = try currentBranch.targetCommit()
            let branchRefName = currentBranch.reference.name

            let prevTree = currentCommit.tree
            let modTree = try index.writeTree()

            if prevTree == modTree {
                return .failure(error: GitInteractionError.nothingChanged_nothingToCommit)
            }

            try repo.createCommit(with: modTree, message: message, parents: [currentCommit], updatingReferenceNamed: branchRefName)
            return .success(value: .affirm)
        } catch {
            return .failure(error: error)
        }
    }

    func push() -> Result<Affirmitive> {
        do {
            let repo = try GTRepository(url: self.repoInfo.clonedURL)
            let branch = try repo.currentBranch()

            guard let remoteName = try repo.remoteNames().first else {
                return .failure(error: GitInteractionError.remoteDoesNotExist)
            }
            let remote = try GTRemote(name: remoteName, in: repo)
            try repo.push(branch, to: remote, withOptions: [:], progress: nil)
            //TODO:- check for network finish status
            return .success(value: .affirm)
        } catch {
            return .failure(error: error)
        }
    }

    func pull() -> Result<Affirmitive>{
        do {
            let repo = try GTRepository(url: self.repoInfo.clonedURL)
            let branch = try repo.currentBranch()

            guard let remoteName = try repo.remoteNames().first else {
                return .failure(error: GitInteractionError.remoteDoesNotExist)
            }
            let remote = try GTRemote(name: remoteName, in: repo)
            try repo.pull(branch, from: remote, withOptions: [:], progress: nil)
            return .success(value: .affirm)
        } catch {
            return .failure(error: error)
        }
    }

    func stash() -> Result<Affirmitive> {
        return .failure(error: NSError(domain: "git interaction to  be implemented", code: 123, userInfo: nil))
    }

}
