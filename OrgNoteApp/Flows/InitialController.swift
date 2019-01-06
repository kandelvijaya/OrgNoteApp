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
    let repoName: String
    let remoteURL: URL
    let clonedURL: URL
}

struct UserState {
    let oauth2Client: BitbucketOauth2
    var userSelectedRepo: UserSelectedRepository?

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
            return LocateUserRepoController.create(with: self)
        default:
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
    }

}
