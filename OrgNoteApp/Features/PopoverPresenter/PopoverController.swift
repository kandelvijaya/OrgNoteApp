//
//  UIViewController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 25.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit


final class PopoverController: UIViewController{

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!

    private var containerController: UIViewController!

    static func create(embedding controller: UIViewController) -> PopoverController{
        let this = UIStoryboard(name: "PopoverController", bundle: Bundle.main).instantiateInitialViewController() as! PopoverController
        this.containerController = controller
        return this
    }

    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        embedController()
        view.bindToKeyboard()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addVisualEffectsToRootView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeVisualEffect()
    }

    private var blurView: UIVisualEffectView?

    private func addVisualEffectsToRootView() {
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.effect = nil
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        UIView.animate(withDuration: 0.3) {
            blurView.effect = blurEffect
        }
    }

    private func removeVisualEffect() {
        UIView.animate(withDuration: 0.3) {
            self.blurView?.effect = nil
        }
    }

    private func embedController() {
        containerController.willMove(toParentViewController: self)
        containerView.addSubview(containerController.view)
        containerController.view.frame = containerView.bounds
        containerController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addChildViewController(containerController)
        containerController.didMove(toParentViewController: self)
    }

}


extension UIView {

    func bindToKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    @objc func keyboardWillChange(_ notification: NSNotification){
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt
        let beginningFrame = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let endFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue



        let deltaY = endFrame.origin.y - beginningFrame.origin.y

        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIViewKeyframeAnimationOptions(rawValue: curve), animations: {
            self.frame.origin.y += deltaY
        }, completion: nil)
    }

}
