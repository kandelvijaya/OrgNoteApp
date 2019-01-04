//
//  OrgNoteInitialFlowController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 04.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit

enum State {
    case userNeedsToAuthorize
    case userIsAuthorizedButHasNotSelectedAnyRepo
    case userIsAuthorizedAndHasSelectedRepo(repo: String)
    case userWantsToViewNote(noteURL: URL)

    var associatedController: UIViewController {
        switch self {
        case .userNeedsToAuthorize:
            return AuthorizeController.created
        default:
           return UIViewController()
        }
    }
}

final class InitialController: UIViewController {

    private var embeddedController: UIViewController?
    private var state: State! {
        willSet {
            embeddedController.map(org_removeChildController)
        }

        didSet {
            embeddedController = state.associatedController
            org_addChildController(state.associatedController)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.state = OrgFlowController().currentState
    }

}


struct OrgFlowController {

    private let cache: BitbucketCache

    init(cache: BitbucketCache = BitbucketCache()) {
        self.cache = cache
    }

    var currentState: State {
        if cache.clientSecret == nil {
            return .userNeedsToAuthorize
        } else {
            return .userIsAuthorizedButHasNotSelectedAnyRepo
        }
    }


}
