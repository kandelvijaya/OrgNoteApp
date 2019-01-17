//
//  OrgParserFlattened.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 17.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation
import SwiftyParserCombinator


extension OrgParser {

    static func parse_flattened(_ contents: String) -> OrgFile? {
        return OrgParser().parse_flattened(contents)
    }

    func parse_flattened(_ contents: String) -> OrgFile? {
        let parser = comments() ->>- orgParser_flattenedOutlineOrdered() |>> {
            OutlineTop(comments: $0.0, outlines_flat: $0.1)
        }
        let parsed = parser |> run(contents)
        guard let flattened = parsed.value()?.0 else {
            assertionFailure("can't parse org file")
            return nil
        }

        let subItems = flattened.outlines_flat

        var graphContainer = GraphContainer<OutlineTop.Item>(with: OutlineTop.Item.rootItem)
        subItems.forEach { item in
            graphContainer.add(item)
        }

        let orgFile = OrgFile.init(topComments: flattened.comments, outlines: graphContainer.allSubItems(of: graphContainer.root))

        return orgFile
    }
    

}


extension OutlineTop.Item : DepthReportable {

    var depth: Int {
        return self.heading.depth
    }
}

extension OutlineTop.Item {

    static var rootItem: OutlineTop.Item {
        return OutlineTop.Item.init(heading: OutlineHeading.init(title: "root", depth: 0), content: [])
    }

    var nodeItem: GraphContainer<OutlineTop.Item>.Node<OutlineTop.Item> {
        return GraphContainer.Node(item: self, next: [], prev: nil)
    }

}


extension GraphContainer where T == OutlineTop.Item {

    func allSubItems(of item: Node<OutlineTop.Item>) -> [Outline] {
        return item.subItems(on: self).map { this in
            let thisSubs = self.allSubItems(of: this)
            return Outline(heading: this.item.heading, content: this.item.content, subItems: thisSubs)
        }
    }

}
