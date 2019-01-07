//
//  OrgFlowCurrentState.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 05.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation
import OAuthorize2

enum FlowState {
    case userNeedsToAuthorize
    case userIsAuthorizedButHasNotSelectedAnyRepo
    case userIsAuthorizedAndHasSelectedRepo(repo: UserSelectedRepository)
}

struct OrgFlowCurrentState {

    private let userState: UserState

    init(userState: UserState) {
        self.userState = userState
    }

    var current: FlowState {
        if userState.oauth2Client.isAuthorizationRequired() {
            return .userNeedsToAuthorize
        }
        guard let selectedRepo = userState.userSelectedRepo else {
            return .userIsAuthorizedButHasNotSelectedAnyRepo
        }

        return .userIsAuthorizedAndHasSelectedRepo(repo: selectedRepo)
    }


}
