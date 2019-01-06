//
//  RepositoryDriver.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 05.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit
import Kekka

final class RepositoryItemCell: UITableViewCell {}
typealias RepoModel = BitbucketRepository.Value



struct RepositoryDriver {

    private let models: [RepoModel]
    private let cellIDentifier: String = "cell"

    private var sectionDescs: [ListSectionDescriptor<RepoModel>] {
        return [self.models.map(cellDescriptor) |> ListSectionDescriptor.init(with:)]
    }

    init(with models: [RepoModel]) {
        self.models = models
    }

    func cellDescriptor(for model: RepoModel) -> ListCellDescriptor<RepoModel, UITableViewCell> {
        var desc = ListCellDescriptor<RepoModel, UITableViewCell>(model, identifier: cellIDentifier, cellClass: RepositoryItemCell.self) { cell in
            cell.textLabel?.text = model.full_name
        }

        desc.onSelect = {
            print(model)
        }

        return desc
    }

    lazy var controller: ListViewController = ListViewController(with: self.sectionDescs, style: .plain)

}
