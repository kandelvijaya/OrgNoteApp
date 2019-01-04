//
//  StoryboardAwaker.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 04.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit

protocol StoryboardAwaker: class {

    static var created: Self { get }
    static var storyboardName: String { get }
    static var bundle: Bundle { get }
    static var controllerIdentifier: String { get }
}

extension StoryboardAwaker where Self: UIViewController {

    static var created: Self {
        return UIStoryboard(name: storyboardName, bundle: bundle).instantiateViewController(withIdentifier: controllerIdentifier) as! Self
    }

    static var storyboardName: String {
        return String(describing: self)
    }

    static var bundle: Bundle {
        return Bundle(for: self)
    }

    static var controllerIdentifier: String {
        return String(describing: self)
    }

}
