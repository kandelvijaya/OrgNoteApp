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


final class FlowRoutinNavigationController: UINavigationController {

    private var embeddedController: UIViewController?

    private var state: FlowState! {
        willSet {
            self.popViewController(animated: true)
        }

        didSet {
            self.pushViewController(controller(for: state), animated: true)
        }
    }

    func move(to next: FlowState) {
        self.state = next
    }

    func jump(to state: FlowState) {

    }

    private var userEnviornment = UserState()

    func computeCurrentState() -> FlowState {
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


extension FlowRoutinNavigationController {

    func controller(for state: FlowState) -> UIViewController{
        switch state {
        case .userNeedsToAuthorize:
            return AuthorizeController.create()
        case .userIsAuthorizedButHasNotSelectedAnyRepo:
            return LocateUserRepoController.create(with: self, userState: self.userEnviornment)
        case let .userIsAuthorizedAndHasSelectedRepo(repo: v):
            return RepoExploreCoordinatingController.created(with: self, userSelectedRepo: v)
        }
    }

    func controllerToView(note file: FileItem.File) -> UIViewController {
        guard let fileContents = try? String(contentsOf: file.url), let orgFile = OrgParser.parse(fileContents) else {
            fatalError("File \(file.name) at url \(file.url.path) cant be processed as ORG file")
        }
        let controller = OrgListDriver(with: orgFile).controller
        controller.title = "Viewing \(file.name)"
        return controller
    }

}

extension FlowRoutinNavigationController: LocateUserRepoControllerDelegate {

    func userDidSelectAndCloned(repo: Result<UserSelectedRepository>) {
        if let error = repo.error {
            //TODO:- a toast or notifiation
            print(error)
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


