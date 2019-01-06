//
//  OrgNoteInitialFlowController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 04.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit
import Kekka

struct UserSelectedRepository {
    let model: BitbucketRepository.Value
    let remoteURL: URL
    let clonedURL: URL
}

struct UserState {
    let oauth2Client: BitbucketOauth2
    var userSelectedRepo: UserSelectedRepository?
    var userSelectedFileInRepo: FileItem.File?

    init(with oauth2Client: BitbucketOauth2 = .shared) {
        self.oauth2Client = oauth2Client
    }

}


final class InitialController: UIViewController {

    private var embeddedController: UIViewController?
    private var state: State! {
        willSet {
            embeddedController.map(org_removeChildController)
        }

        didSet {
            embeddedController = controller(for: state)
            org_addChildController(embeddedController!)
        }
    }

    private var userEnviornment = UserState()

    func computeCurrentState() -> State {
        return OrgFlowCurrentState(userState: self.userEnviornment).current
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.state = computeCurrentState()
        setupAccessTokenReceivedNotification()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func setupAccessTokenReceivedNotification() {
        // TODO:- figure out why this is not working.
        NotificationCenter.default.addObserver(forName: userDidReceiveAccessTokenNotification, object: self, queue: .main) { notification in
            self.state = self.computeCurrentState()
        }
    }

}


extension InitialController {

    func controller(for state: State) -> UIViewController{
        switch state {
        case .userNeedsToAuthorize:
            return AuthorizeController.created
        case .userIsAuthorizedButHasNotSelectedAnyRepo:
            return LocateUserRepoController.create(with: self, userState: self.userEnviornment)
        case let .userIsAuthorizedAndHasSelectedRepo(repo: v):
            return RepoExploreCoordinatingController.created(with: self, userSelectedRepo: v)
        case let .userWantsToViewNote(file):
            return UIViewController()
        }
    }

}

extension InitialController: LocateUserRepoControllerDelegate {

    func userDidSelectAndCloned(repo: Result<UserSelectedRepository>) {
        if let error = repo.error {
            //TODO:- a toast or notifiation
            print(error)
        }
        self.userEnviornment.userSelectedRepo = repo.value
        self.state = computeCurrentState()
    }

}


extension InitialController: RepoExploreCoordinatingControllerDelegate {

    func userDidSelectOrgFile(_ file: FileItem.File) {
        if isOrgModeFile(file) {
            userEnviornment.userSelectedFileInRepo = file
            self.state = computeCurrentState()
        } else {
            let oops = UIAlertController(title: "OOPS 😉", message: "We can only process ORG mode file. Please select org mode file to proceed.", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Got it!", style: .cancel) { action in

            }
            oops.addAction(okayAction)
            self.present(oops, animated: true, completion: nil)
        }

    }

    func isOrgModeFile(_ file: FileItem.File) -> Bool {
        // FIXME:- Use also parser
        return file.ext == "org"
    }

}
