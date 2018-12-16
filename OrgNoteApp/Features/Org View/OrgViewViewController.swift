//
//  OrgViewViewController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 25.11.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import UIKit


final class OrgViewViewController: UIViewController {

    @IBOutlet weak var locateViewHeight: NSLayoutConstraint!
    @IBOutlet weak var locateView: UIView!
    @IBOutlet weak var showView: UIView!

    /// FIXME:
    private let previouslyKnownOrgFileExists: OrgFile? =  Mock.OrgFileService().fetchWorkLog().resultingValueIfSynchornous!.value

    private let orgFileRetrivalService = OrgFileRetrieveService(orgParser: OrgParser.parse)

    private var locateVC: OrgLocateViewController?
    private var viewVC: ListViewController<AnyHashable>?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let model = previouslyKnownOrgFileExists {
            embedViewVC(with: model)
            expandShowViewToEntireScreen()
        } else {
            embedLocateVC()
        }
        locateView.backgroundColor = Theme.blueish.alert
        showView.backgroundColor = Theme.blueish.normal
    }

    private func removeLocateVC() {
        locateVC?.removeFromParentViewController()
        locateViewHeight.constant = 0
    }

    private func embedLocateVC() {
        let vc = OrgLocateViewController.create()
        locateVC = vc
        locateVC?.delegate = self
        embed(controller: vc, in: locateView)
    }

    private func embedViewVC(with model: OrgFile) {
        let vc = OrgListDriver(with: model).controller
        viewVC = vc
        embed(controller: vc, in: showView)
    }

    private func embed(controller: UIViewController, in containerView: UIView) {
        controller.willMove(toParentViewController: self)
        addChildViewController(controller)
        containerView.addSubview(controller.view)
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        controller.didMove(toParentViewController: self)
    }

    private func expandShowViewToEntireScreen() {
        locateViewHeight.constant = 0
    }

}


extension OrgViewViewController: OrgLocateViewControllerDelegate {

    func userDidLocateOrgFilePath(_ url: URL) {
        animateOutLocateView()
        loadResourceInShowView(with: url)
    }

    private func animateOutLocateView() {
        view.layoutIfNeeded()
        UIView.animate(withDuration: 1.0, animations: {
            self.locateViewHeight.constant = 0
            self.view.layoutIfNeeded()
        }) { _ in
            self.locateVC?.removeFromParentViewController()
            self.locateView.subviews.forEach { $0.removeFromSuperview() }
        }
    }

    private func loadResourceInShowView(with modelURL: URL) {
        orgFileRetrivalService.retrieveOrgFile(for: modelURL).then { [weak self] res -> Void in
            switch res {
            case let .success(v):
                self?.embedViewVC(with: v)
            case let .failure(e):
                // TODO: Failure
                print(e)
            }
            return
        }.execute()
    }

}
