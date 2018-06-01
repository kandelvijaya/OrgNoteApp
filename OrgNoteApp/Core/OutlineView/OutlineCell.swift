//
//  OutlineCell.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 01.06.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import UIKit

final class OutlineCell: UITableViewCell {

    public func update(with model: Outline) {
        let outlineView = OutlineView()
        outlineView.update(with: model)
        contentView.embed(outlineView)
    }

}


extension UIView {

    public func embed(_ view: UIView) {
        let holder = self
        let child = view

        holder.translatesAutoresizingMaskIntoConstraints = false
        holder.addSubview(child)
        let cons = [child.leadingAnchor.constraint(equalTo: holder.leadingAnchor),
                    child.trailingAnchor.constraint(equalTo: holder.trailingAnchor),
                    child.topAnchor.constraint(equalTo: holder.topAnchor),
                    child.bottomAnchor.constraint(equalTo: holder.bottomAnchor)]
        cons.forEach { $0.isActive = true }
    }

}
