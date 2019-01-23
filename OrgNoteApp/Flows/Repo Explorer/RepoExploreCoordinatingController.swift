//
//  RepoExploreCoordinatingController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 06.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit

protocol RepoExploreCoordinatingControllerDelegate: class {
    func userDidSelectOrgFile(_ file: FileItem.File)
    func userWantsToRefreshRepoContents(for repo: UserSelectedRepository)
}

final class RepoExploreCoordinatingController: UIViewController, StoryboardAwaker {

    private weak var delegate: RepoExploreCoordinatingControllerDelegate?
    private var userSelectedRepo: UserSelectedRepository!

    static func created(with delegate: RepoExploreCoordinatingControllerDelegate, userSelectedRepo: UserSelectedRepository) -> UIViewController {
        let controller = created
        controller.delegate = delegate
        controller.userSelectedRepo = userSelectedRepo
        controller.title = "Select note"
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let repoItem = FileItem.buildFileItem(from: self.userSelectedRepo)
        switch repoItem {
        case let .directory(dir):
            var driver = RepoExploreDriver(with: dir.subItems, parent: repoItem, onNavigationController: navigationController!, onFileSelected: onFileSelected, onRefreshRepo: onRefreshContents)
            let controller = driver.controller
            org_addChildController(controller)
        default:
            assertionFailure("Expected Directory found file!")
        }
    }

    private func onFileSelected(_ item: FileItem.File) {
        delegate?.userDidSelectOrgFile(item)
    }

    private func onRefreshContents() {
        delegate?.userWantsToRefreshRepoContents(for: self.userSelectedRepo)
    }

}
