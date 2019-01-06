//
//  RepoExplorerController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 06.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation
import UIKit
import Kekka


final class FileItemCell: UITableViewCell { }

struct RepoExploreDriver {

    private let models: [FileItem]
    private let navController: UINavigationController

    var onFileSelected: (FileItem.File) -> Void

    init(with items: [FileItem], parent: FileItem?, onNavigationController: UINavigationController,onFileSelected: @escaping (FileItem.File) -> Void) {
        self.navController = onNavigationController
        self.models = items
        self.onFileSelected = onFileSelected
        onNavigationController.pushViewController(controller, animated: true)
        if let parent = parent {
            onNavigationController.title = parent.name
        }
    }

    private lazy var controller: UIViewController = {
        let sectionDescs = [ self.models.map(self.cellDescriptor) |> ListSectionDescriptor.init ]
        let controller = ListViewController(with: sectionDescs, style: .plain)
        return controller
    }()

    private let identifier = "cell"

    func cellDescriptor(_ item: FileItem) -> ListCellDescriptor<FileItem, UITableViewCell> {
        var cellDesc = ListCellDescriptor<FileItem, UITableViewCell>(item, identifier: identifier, cellClass: FileItemCell.self) { cell in
            cell.textLabel?.text = item.name
            switch item {
            case let .directory(dir):
                cell.backgroundColor = .yellow
                cell.detailTextLabel?.text = "Dir with \(dir.subItems.count) items"
            case let .file(file):
                cell.backgroundColor = .white
                cell.detailTextLabel?.text = "FileType: \(file.ext ?? "-")"
            }
        }
        cellDesc.onSelect = {
            self.itemSelected(item)
        }
        return cellDesc
    }

    private func itemSelected(_ item: FileItem) {
        switch item {
        case let .directory(dir):
            self.push(dir.subItems, from: item)
        case let .file(f):
            onFileSelected(f)
        }
    }

    private func push(_ items: [FileItem], from: FileItem) {
        _ = RepoExploreDriver(with: items, parent: from, onNavigationController: navController, onFileSelected: onFileSelected)
    }



}
