//
//  EditableGenericList.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 17.12.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import Kekka
import UIKit

final class EditableListController<T: Hashable>: ListViewController<T> {

    override func viewDidLoad() {
        super.viewDidLoad()
        let longTapGestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(longPressedOnCell(_:)))
        tableView.addGestureRecognizer(longTapGestureRecogniser)
    }

    /// This property is used to mark this indexPath is the only one that supports editing
    /// We dont want other index path to show editing enabled
    private var currentlyPressedIndexPath: IndexPath?

    @objc private func longPressedOnCell(_ gestureRecogniser: UILongPressGestureRecognizer) {
        guard gestureRecogniser.state == .began else { return }
        guard let pressedIndexPath = gestureRecogniser.location(in: tableView) |> tableView.indexPathForRow else {
            tableView.setEditing(false, animated: true)
            return
        }

        // removes all editing style
        if let previous = currentlyPressedIndexPath {
            tableView.setEditing(false, animated: true)

            // if long pressed on the cell for second time, remove the editing mode and exit
            if previous == pressedIndexPath {
                currentlyPressedIndexPath = nil
                return
            }
        }

        currentlyPressedIndexPath = pressedIndexPath

        // add editing styles
        tableView.setEditing(true, animated: true)
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        guard let selected = currentlyPressedIndexPath else { return .none }
        return selected == indexPath ? .insert : .none
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let selected = currentlyPressedIndexPath else { return true }
        return selected == indexPath
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let moreAction = UITableViewRowAction(style: .normal, title: "More...") { (action, indexPath) in
            self.model(at: indexPath).onPerfromAction?(.changeStatus)
        }
        moreAction.backgroundColor = Theme.blueish.normal.withAlphaComponent(0.7)

        let removeAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.model(at: indexPath).onPerfromAction?(.deleteItem)
        }

        return [moreAction, removeAction]
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert {
            self.model(at: indexPath).onPerfromAction?(OutlineAction.addItemBelow)
        }
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addAction = UIContextualAction(style: .normal, title: "Add") { (action, view, completion) in
            self.model(at: indexPath).onPerfromAction?(OutlineAction.addItemBelow)
            completion(true)
        }
        addAction.backgroundColor = Theme.blueish.normal
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            self.model(at: indexPath).onPerfromAction?(OutlineAction.editItem)
            completion(true)
        }
        editAction.backgroundColor = Theme.blueish.normal.withAlphaComponent(0.7)
        let config = UISwipeActionsConfiguration(actions: [addAction, editAction])
        return config
    }

}
