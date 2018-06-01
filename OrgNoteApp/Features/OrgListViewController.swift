//
//  WorkLogViewController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 01.06.18.
//  Copyright © 2018 com.kandelvijaya. All rights reserved.
//

import Foundation
import Kekka


class OrgListFactoryTemp {

    var cells: [AnyListCellDescriptor] {
        let model = Mock.OrgFileService().fetchWorkLog().resultingValueIfSynchornous!.value!
        return model.map { m in
            ListCellDescriptor<Outline, OutlineCell>(m, identifier: "OutlineCell", cellClass: OutlineCell.self, configure: { cell in
                cell.update(with: m)
            }).any()
        }
    }

    lazy var sections = [ListSectionDescriptor(with: cells)]

}
