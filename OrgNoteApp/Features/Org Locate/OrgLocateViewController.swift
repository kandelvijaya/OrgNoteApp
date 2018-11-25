//
//  OrgLocateViewController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 25.11.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import UIKit

protocol Initializable {

    static func create() -> Self

}


final class OrgLocateViewController: UIViewController, Initializable {

    static func create() -> OrgLocateViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: OrgLocateViewController.self)) as! OrgLocateViewController
        return vc
    }

}
