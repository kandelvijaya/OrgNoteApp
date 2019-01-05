//
//  OrgFlowCurrentState.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 05.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation
import OAuthorize2

enum State {
    case userNeedsToAuthorize
    case userIsAuthorizedButHasNotSelectedAnyRepo
    case userIsAuthorizedAndHasSelectedRepo(repo: UserSelectedRepository)
    case userWantsToViewNote(noteURL: URL)
}

struct OrgFlowCurrentState {

    private let userState: UserState

    init(userState: UserState) {
        self.userState = userState
    }

    var current: State {
        if userState.oauth2Client.isAuthorizationRequired() {
            return .userNeedsToAuthorize
        }
        guard let selectedRepo = userState.userSelectedRepo else {
            return .userIsAuthorizedButHasNotSelectedAnyRepo
        }

        return .userIsAuthorizedAndHasSelectedRepo(repo: selectedRepo)
    }


}
