//
//  FlowRoutingNavigationController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 07.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit
import Kekka
import FastDiff
import OAuthorize2

final class FlowRoutinNavigationController: UINavigationController {

    private var embeddedController: UIViewController?

    private var state: FlowState! {
        didSet {
            self.pushViewController(controller(for: state), animated: true)
        }
    }

    func move(to next: FlowState) {
        self.state = next
    }

    private var userEnviornment = UserState()

    func computeCurrentState() -> FlowState {
        return OrgFlowCurrentState(userState: self.userEnviornment).current
    }

    func computeAllInitialStates() -> [FlowState] {
        return OrgFlowCurrentState(userState: self.userEnviornment).allStatesInOrder
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = true
        initiateTokenRefresh()
        computeAllInitialStates().forEach { s in
            self.state = s
        }
    }

    private func initiateTokenRefresh() {
        userEnviornment.oauth2Client.refreshAccessToken().then { item -> Void in
            if case let .failure(error: e) = item {
                print(e)
            } else {
                print("Access token refreshed!")
            }
        }.execute()
    }

    private func setupAccessTokenReceivedNotification() {
        NotificationCenter.default.addObserver(forName: userDidReceiveAccessTokenNotification, object: nil, queue: .main) { notification in
            self.state = self.computeCurrentState()
        }
    }

}


extension FlowRoutinNavigationController {

    func controller(for state: FlowState) -> UIViewController{
        switch state {
        case .userNeedsToAuthorize:
            return AuthorizeController.created { [weak self] in
                self?.state = .userIsAuthorizedButHasNotSelectedAnyRepo
            }
        case .userIsAuthorizedButHasNotSelectedAnyRepo:
            return LocateUserRepoController.create(with: self, userState: self.userEnviornment)
        case let .userIsAuthorizedAndHasSelectedRepo(repo: v):
            return RepoExploreCoordinatingController.created(with: self, userSelectedRepo: v)
        }
    }

    func controllerToView(note file: FileItem.File) -> UIViewController {
        let controller = OrgViewEditCoordinatingController.created(with: file, userSelectedRepo: userEnviornment.userSelectedRepo!, onExit: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        })
        return controller
    }

}

extension FlowRoutinNavigationController: LocateUserRepoControllerDelegate {

    func userDidSelectAndCloned(repo: Result<UserSelectedRepository>) {
        if let error = repo.error {
            AlertController.alertNegative("Failed to clone the repo! \n \(error.localizedDescription)")
        }
        self.userEnviornment.userSelectedRepo = repo.value
        self.state = computeCurrentState()
    }

}


extension FlowRoutinNavigationController: RepoExploreCoordinatingControllerDelegate {

    func userDidSelectOrgFile(_ file: FileItem.File) {
        if isOrgModeFile(file) {
            self.pushViewController(controllerToView(note: file), animated: true)
        } else {
            let oops = UIAlertController(title: "OOPS 😉", message: "We can only process ORG mode file. Please select org mode file to proceed.", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Got it!", style: .cancel) { _ in  }
            oops.addAction(okayAction)
            self.present(oops, animated: true, completion: nil)
        }

    }

    func userWantsToRefreshRepoContents(for repo: UserSelectedRepository) {
        let git = Git(repoInfo: repo)
        let action = git.pull()
        let success = action.value != nil
        if success {
            // we know its going to be the only one on top
            self.navigationController?.popViewController(animated: true)
            self.state = computeCurrentState()
            AlertController.alertPositive("Repo is pulled successfully")
        } else {
            // no-op. show error
            AlertController.alertNegative("cant pull to refresh for given repo \n \(action.error!.localizedDescription)")
        }
    }

    func isOrgModeFile(_ file: FileItem.File) -> Bool {
        let content = try! String(contentsOf: file.url)
        let parsed = OrgParser.parse(content)
        return file.ext == "org" && parsed != nil
    }

}
