//
//  UIViewExtensions.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 04.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit
import Kekka

func asyncOnMain(_ block: @escaping ClosedBlock) {
    DispatchQueue.main.async(execute: block)
}

extension UIViewController {

    public func org_addChildController(_ child: UIViewController, toView: UIView? = nil, frame: CGRect? = nil, isAsync: Bool = false, completion: @escaping () -> Void = {}) {
        let operation: () -> Void = { [weak self] in
            guard let this = self else { return }
            guard let contentView = toView ?? this.view, this.isViewLoaded else { return }
            this.addChild(child)
            child.view.frame = frame ?? contentView.bounds
            child.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            contentView.addSubview(child.view)
            child.didMove(toParent: this)
            completion()
        }
        if isAsync {
            asyncOnMain(operation)
        } else {
            operation()
        }
    }

    public func org_removeChildController(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.didMove(toParent: nil)
    }

}
