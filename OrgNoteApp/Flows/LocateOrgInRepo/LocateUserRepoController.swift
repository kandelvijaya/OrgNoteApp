
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

protocol LocateUserRepoControllerDelegate: class {
    func userDidSelectAndCloned(repo: Result<UserSelectedRepository>)
}

final class LocateUserRepoController: UIViewController, StoryboardAwaker {

    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    private weak var delegate: LocateUserRepoControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        indicatorView.startAnimating()
        BitbucketAPI().fetchRepositories().then { item in
            print(item.error)
            self.createAndEmbedRepositoryList(with: item.value?.values ?? [])
        }.execute()
    }

    private func createAndEmbedRepositoryList(with repos: [BitbucketRepository.Value]) {
        var driver = RepositoryDriver(with: repos)
        org_addChildController(driver.controller)
    }

    static func create(with delegate: LocateUserRepoControllerDelegate) -> LocateUserRepoController {
        let controller = created
        created.delegate = delegate
        return controller
    }

}


