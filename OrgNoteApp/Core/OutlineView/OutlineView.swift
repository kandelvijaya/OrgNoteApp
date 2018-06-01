//
//  OutlineView.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 01.06.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import UIKit

final class OutlineView: UIView {

    private var heading: UILabel = UILabel()
    private var content: UILabel = UILabel()
    private var subItemView: [OutlineView] = []


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with outline: Outline) {
        heading.text = "*".replicate(outline.heading.depth) + "  " + outline.heading.title
        content.text = outline.content.joined()
    }

    private func setupConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        let headingCons = [heading.topAnchor.constraint(equalTo: self.topAnchor),
        heading.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        heading.trailingAnchor.constraint(equalTo: self.trailingAnchor)]
        self.addConstraints(headingCons)

        let contentCons = [content.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
                           content.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
                           content.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)]
        self.addConstraints(contentCons)
    }

}


extension Character {

    func replicate(_ times: Int) -> String {
        return [Character](repeating: self, count: times)
                .map(String.init)
                .reduce("", +)
    }

}

extension String {

    func replicate(_ times: Int) -> String {
        return [String](repeating: self, count: times).reduce("", +)
    }

}


