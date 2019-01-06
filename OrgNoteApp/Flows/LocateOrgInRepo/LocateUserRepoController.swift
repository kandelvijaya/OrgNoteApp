
//
//  LocateUserRepoController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 05.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit
import Kekka
import ObjectiveGit

protocol LocateUserRepoControllerDelegate: class {
    func userDidSelectAndCloned(repo: Result<UserSelectedRepository>)
}

final class LocateUserRepoController: UIViewController, StoryboardAwaker {

    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    private weak var delegate: LocateUserRepoControllerDelegate?
    private var userState: UserState?

    override func viewDidLoad() {
        super.viewDidLoad()
        indicatorView.startAnimating()
        BitbucketAPI().fetchRepositories().then { item in
            switch item {
            case let .success(value: v):
                self.createAndEmbedRepositoryList(with: v.values)
            case let .failure(error: e):
                // TODO:-
                self.indicatorView.stopAnimating()
                print(e)
            }

        }.execute()
    }

    private func createAndEmbedRepositoryList(with repos: [BitbucketRepository.Value]) {
        var driver = RepositoryDriver(with: repos, onSelect: self.repositorySelected)
        org_addChildController(driver.controller)
    }

    static func create(with delegate: LocateUserRepoControllerDelegate, userState: UserState) -> LocateUserRepoController {
        let controller = created
        controller.delegate = delegate
        controller.userState = userState
        return controller
    }

    private func repositorySelected(_ repoModel: BitbucketRepository.Value) {
        guard let client = userState?.oauth2Client, let accessToken = client.accessTokenStorageService.retrieve(tokenFor: client.config) else {
            fatalError("Access Token Not found")
        }
        let cloneResult = BitbucketClone(with: accessToken.accessToken).clone(repoModel)
        print(cloneResult)
    }

}


