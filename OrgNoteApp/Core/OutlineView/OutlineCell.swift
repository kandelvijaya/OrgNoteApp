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
    private let holder = UIView()
    private var holderToContentViewSpacing: NSLayoutConstraint?

    public func update(with model: OutlineViewModel) {
        outlineView.update(with: model)
        contentView.backgroundColor = model.indicativeBackgroundColor
        embedInContentView(outlineView, reflectingDepth: model.indentationLevel)
    }

    public func embedInContentView(_ view: UIView, reflectingDepth depth: Int) {
        let layoutInfo = contentView.embed(holder)
        holderToContentViewSpacing = layoutInfo.left
        holder.embed(view)
        layoutInfo.left.constant = indentationWidth * CGFloat(depth)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.subviews.forEach { $0.removeFromSuperview() }
        outlineView.clearContents()
    }

}


extension UIView {

    public struct LayoutInfo {
        let left: NSLayoutConstraint
        let right: NSLayoutConstraint
        let top: NSLayoutConstraint
        let bottom: NSLayoutConstraint
    }

    @discardableResult public func embed(_ view: UIView) -> LayoutInfo  {
        let holder = self
        let child = view

        child.translatesAutoresizingMaskIntoConstraints = false
        holder.addSubview(child)
        let cons = [child.leadingAnchor.constraint(equalTo: holder.leadingAnchor),
                    child.trailingAnchor.constraint(equalTo: holder.trailingAnchor),
                    child.topAnchor.constraint(equalTo: holder.topAnchor),
                    child.bottomAnchor.constraint(equalTo: holder.bottomAnchor)]
        cons.forEach { $0.isActive = true }

        return LayoutInfo(left: cons[0], right: cons[1], top: cons[2], bottom: cons[3])
    }

}
