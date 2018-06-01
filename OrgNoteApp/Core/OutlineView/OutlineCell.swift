//
//  OutlineCell.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 01.06.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import UIKit

final class OutlineCell: UITableViewCell {

    init(with outlineView: OutlineView) {
        super.init(style: .default, reuseIdentifier: "OutlineCell")
        embed(outlineView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


extension UIView {

    func embed(_ view: UIView) {
        let holder = self
        let child = view

        holder.translatesAutoresizingMaskIntoConstraints = false
        holder.addSubview(child)
        let cons = [child.leadingAnchor.constraint(equalTo: holder.leadingAnchor),
                    child.trailingAnchor.constraint(equalTo: holder.trailingAnchor),
                    child.topAnchor.constraint(equalTo: holder.topAnchor),
                    child.bottomAnchor.constraint(equalTo: holder.bottomAnchor)]
        holder.addConstraints(cons)
    }

}
