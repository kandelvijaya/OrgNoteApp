//
//  MainCoordinator.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 13.05.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import UIKit

protocol Navigator {
    var childNavigators: [Navigator] { get }
    var navigationController: UINavigationController { get }
    func start()
}



struct MainNavigator: Navigator {

    var childNavigators: [Navigator] = []

    let navigationController: UINavigationController

    init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewController = ViewController()
        navigationController.pushViewController(viewController, animated: true)
    }

}
