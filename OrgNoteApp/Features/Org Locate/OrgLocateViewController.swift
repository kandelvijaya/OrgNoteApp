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

protocol OrgLocateViewControllerDelegate: class {
    func userDidLocateOrgFilePath(_ url: URL)
}


final class OrgLocateViewController: UIViewController, Initializable {

    static func create() -> OrgLocateViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: OrgLocateViewController.self)) as! OrgLocateViewController
        return vc
    }

    weak var delegate: OrgLocateViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewNoteButton.tintColor = Theme.blueish.buttonTint
    }

    @IBOutlet weak var viewNoteButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var secondaryLabel: UILabel!

    @IBAction func viewNoteButtonTapped(_ sender: UIButton) {
        guard let urlText = textField.text else {
            secondaryLabel.text = "Cannot locate resource. Path is empty"
            return
        }
        guard let url = URL(string: urlText) else {
            secondaryLabel.text = "\(urlText) is not a valid URL path."
            return
        }
        delegate?.userDidLocateOrgFilePath(url)
        textField.text = nil
    }

}

