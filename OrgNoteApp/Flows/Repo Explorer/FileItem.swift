//
//  FileItem.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 06.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import Foundation

enum FileItem: Hashable {

    case file(File), directory(Directory)

    struct File: Hashable {
        let url: URL
        let name: String
        let ext: String?
    }

    struct Directory: Hashable {
        let url: URL
        let name: String
        let subItems: [FileItem]
    }

    var name: String {
        switch self {
        case let .file(item):
            return item.name
        case let .directory(dir):
            return dir.name
        }
    }

    var url: URL {
        switch self {
        case let .file(item):
            return item.url
        case let .directory(dir):
            return dir.url
        }
    }

}



extension FileItem {

    static func buildFileItem(from repo: UserSelectedRepository) ->  FileItem {
        let subItems = findAllFileItems(atDirectoryURL: repo.clonedURL)
        let item = FileItem.directory(Directory(url: repo.clonedURL, name: repo.model.full_name, subItems: subItems))
        return item
    }

    static func findAllFileItems(atDirectoryURL: URL) -> [FileItem] {
        let mgr = FileManager.default
        guard let items = try? mgr.contentsOfDirectory(at: atDirectoryURL, includingPropertiesForKeys: [], options: .skipsHiddenFiles) else {
            assertionFailure("couldnt find items at the given url. This url is either invalid or is not a directory url. Please revise")
            return []
        }

        var accumulator: [FileItem] = []
        for indexURL in items {
            let attributes = try! mgr.attributesOfItem(atPath: indexURL.path)
            let isDirectory = (attributes[FileAttributeKey.type] as! FileAttributeType) == FileAttributeType.typeDirectory
            let name = indexURL.lastPathComponent

            if isDirectory {
                let subItems = findAllFileItems(atDirectoryURL: indexURL)
                let item = FileItem.directory(Directory(url: indexURL, name: name, subItems: subItems))
                accumulator.append(item)
            } else {
                let ext = name.split(separator: ".").last.map{ String($0) }
                let item = FileItem.file(File(url: indexURL, name: name, ext: ext))
                accumulator.append(item)
            }
        }
        return accumulator
    }

}
