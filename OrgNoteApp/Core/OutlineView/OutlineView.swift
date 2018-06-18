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
    private let subItemsStackView = UIStackView()


    override init(frame: CGRect) {
        super.init(frame: frame)
        heading.numberOfLines = 0
        content.numberOfLines = 0 
        addSubview(heading)
        addSubview(content)
        addSubview(subItemsStackView)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with outline: Outline) {
        heading.text = "*".replicate(outline.heading.depth) + "  " + outline.heading.title
        content.text = outline.content.joined(separator: "\n")
        updateConstraintsIfNeeded()
    }

    private func setupConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        heading.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        subItemsStackView.translatesAutoresizingMaskIntoConstraints = false

        let headingCons = [heading.topAnchor.constraint(equalTo: self.topAnchor),
                           heading.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                           heading.trailingAnchor.constraint(equalTo: self.trailingAnchor)
                        ]
        self.addConstraints(headingCons)

        let contentCons = [content.leadingAnchor.constraint(equalTo: heading.leadingAnchor, constant: 10),
                           content.topAnchor.constraint(equalTo: heading.bottomAnchor, constant: 10),
                           content.trailingAnchor.constraint(equalTo: heading.trailingAnchor, constant: 0),
        ]
        self.addConstraints(contentCons)

        let stackViewCons = [subItemsStackView.topAnchor.constraint(equalTo: content.bottomAnchor),
                             subItemsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                             subItemsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                             subItemsStackView.trailingAnchor.constraint(equalTo: trailingAnchor)]
        self.addConstraints(stackViewCons)
        subItemsStackView.axis = .vertical
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


