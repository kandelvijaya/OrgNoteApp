//
//  OutlineCell.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 01.06.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import UIKit

final class OutlineCell: UITableViewCell {

    lazy var outlineView = OutlineView()

    public func update(with model: OutlineViewModel) {
        outlineView.update(with: model)
        embedInContentView(outlineView)
    }

    public func embedInContentView(_ view: UIView) {
        let holder = UIView()
        contentView.addSubview(holder)

        let consToContentView = [ holder.topAnchor.constraint(equalTo: contentView.topAnchor),
                                  holder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                                  holder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                                  holder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)]
        consToContentView.forEach {
            $0.isActive = true 
        }

        let child = view

        holder.translatesAutoresizingMaskIntoConstraints = false
        child.translatesAutoresizingMaskIntoConstraints = false

        holder.addSubview(child)
        let cons = [child.leadingAnchor.constraint(equalTo: holder.leadingAnchor),
                    child.trailingAnchor.constraint(equalTo: holder.trailingAnchor),
                    child.topAnchor.constraint(equalTo: holder.topAnchor),
                    child.bottomAnchor.constraint(equalTo: holder.bottomAnchor)]
        cons.forEach { $0.isActive = true }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        outlineView.clearContents()
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
