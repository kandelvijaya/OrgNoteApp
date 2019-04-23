//
//  StoryboardInitializable.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 25.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit

protocol StoryboardInitializable: class {

    static var storyboardName: String { get }
    static var controllerIdentifier: String { get }
    static var bundle: Bundle { get }
    static func create() -> Self

}

extension StoryboardInitializable where Self: UIViewController {

    static var controllerIdentifier: String {
        return String(describing: "\(self)")
    }

    static var bundle: Bundle {
        return Bundle.main
    }

    static func create() -> Self {
        return UIStoryboard(name: self.storyboardName, bundle: self.bundle).instantiateViewController(withIdentifier: self.controllerIdentifier) as! Self
    }

}
