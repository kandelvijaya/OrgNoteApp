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
}

final class RepoExploreCoordinatingController: UIViewController, StoryboardAwaker {

    private weak var delegate: RepoExploreCoordinatingControllerDelegate?
    private var userSelectedRepo: UserSelectedRepository!

    static func created(with delegate: RepoExploreCoordinatingControllerDelegate, userSelectedRepo: UserSelectedRepository) -> UIViewController {
        let controller = created
        controller.delegate = delegate
        controller.userSelectedRepo = userSelectedRepo
        let navigationController = UINavigationController(rootViewController: controller)
        return navigationController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let repoItem = FileItem.buildFileItem(from: self.userSelectedRepo)
        switch repoItem {
        case let .directory(dir):
            let _ = RepoExploreDriver(with: dir.subItems, parent: repoItem, onNavigationController: self.navigationController!, onFileSelected: self.onFileSelected)
        default:
            assertionFailure("Expected Directory found file!")
        }
    }

    private func onFileSelected(_ item: FileItem.File) {
        delegate?.userDidSelectOrgFile(item)
    }

}
