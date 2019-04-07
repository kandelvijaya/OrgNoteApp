//
//  OrgViewEditCoordinatingController.swift
//  OrgNoteApp
//
//  Created by Vijaya Prakash Kandel on 27.01.19.
//  Copyright © 2019 com.kandelvijaya. All rights reserved.
//

import UIKit

final class OrgViewEditCoordinatingController: UIViewController {

    enum State {
        case list
        case editor
    }

    private var onExit: ClosedBlock!
    private var noteToView: FileItem.File!
    private var initialOrgFile: OrgFile!
//    private var userSelectedRepo: UserSelectedRepository!

    static func created(with note: FileItem.File, /* userSelectedRepo: UserSelectedRepository,*/ onExit: @escaping ClosedBlock = {} ) -> OrgViewEditCoordinatingController {
        let controller = OrgViewEditCoordinatingController()
        controller.onExit = onExit
        controller.noteToView = note
//        controller.userSelectedRepo = userSelectedRepo
        controller.initialOrgFile = controller.inputOrgFile
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Viewing \(noteToView.name)"
        view.backgroundColor = .white
        update(to: .list)
        addRightBarButton()
        addLeftBarButton()
    }
    
    private func addLeftBarButton() {
        let exitButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(exitOrg))
        self.navigationItem.leftBarButtonItems = [exitButton]
    }

    private func addRightBarButton() {
        let toggleBarItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(toggleEditor(_:)))
        self.navigationItem.rightBarButtonItems = [toggleBarItem]
    }

    @IBAction func toggleEditor(_ sneder: UIButton) {
        switch currentState {
        case .list:
            update(to: .editor)
        case .editor:
            update(to: .list)
        }
    }

    private var currentChildController: UIViewController?
    private var currentState: State = .list

    private func update(to mode: State) {
        self.currentState = mode
        reset()
        switch mode {
        case .list:
            addController(listController())
        case .editor:
            addController(editor())
        }
    }

    private func reset() {
        self.view.subviews.forEach { $0.removeFromSuperview() }
        self.currentChildController.map { $0.removeFromParentViewController() }
    }

    private func addController(_ vc: UIViewController) {
        vc.willMove(toParentViewController: self)
        self.view.addSubview(vc.view)
        vc.view.frame = self.view.bounds
        //view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        [vc.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
         vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
         vc.view.leftAnchor.constraint(equalTo: view.leftAnchor),
         vc.view.rightAnchor.constraint(equalTo: view.rightAnchor)].forEach { $0.isActive = true }

        vc.didMove(toParentViewController: self)
        self.currentChildController = vc
    }


    private func editor() -> UIViewController {
        let driver = OrgRawEditorDriver(with: inputOrgFile) { [weak self] newOrgFile in
            guard let this = self else { return }
            guard let newOrgFile = newOrgFile else {
                assertionFailure("Invlaid org file detected")
                this.onExit()
                return
            }
            this.saveToDisk(with: this.inputOrgFile, new: newOrgFile)
        }
        return driver.controller
    }

    private var inputOrgFile: OrgFile {
        guard let fileContents = try? String(contentsOf: noteToView.url), let orgFile = OrgParser.parse(fileContents) else {
            fatalError("File \(noteToView.name) at url \(noteToView.url.path) cant be processed as ORG file")
        }
        return orgFile
    }

    private func listController() -> ListViewController<AnyHashable> {
        let controller = OrgListDriver(with: inputOrgFile, onExit: { [weak self] newOrgFile in
            guard let this = self else { return }
            this.saveToDisk(with: this.inputOrgFile, new: newOrgFile)
        }).controller
        return controller
    }

    private func saveToDisk(with orgFile: OrgFile, new newOrgFile: OrgFile) {
        // NOTE:- comparing orgFile and newOrgFile is incorrect as we dont care about isExpaneded property.
        if orgFile.fileString != newOrgFile.fileString {
            let newContent = newOrgFile.fileString
            let writing = doTry { try newContent.write(to: noteToView.url, atomically: true, encoding: .utf8) }
            assert(writing.error == nil, "Something happend wrong during writing orgfile to file \(noteToView.url.path)")
        }
    }

//    private func addCommitPush(_ file: FileItem.File) {
//        guard let git = userSelectedRepo.map({ Git(repoInfo: $0) }) else {
//            return
//        }
//        let result = git.addAll().flatMap { _ in
//            git.commit(with: "@synced From @app @\(NSDate().timeIntervalSince1970) @ \(file.name)")
//            }.flatMap { _ in
//                git.push()
//        }
//
//        if result.value != nil {
//            AlertController.alertPositive("Good! Your file changes is pushed to remote.")
//        } else {
//            AlertController.alertNegative("OOPS! Your file changes is NOT synced. \n \(result.error!.localizedDescription)")
//        }
//    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.currentChildController?.viewWillDisappear(animated)    // This is so that the internal model can save to disk before we commit
        if inputOrgFile.fileString != initialOrgFile.fileString {
//            self.addCommitPush(noteToView)
        }
        self.onExit()
    }
    
    @objc private func exitOrg() {
        self.onExit()
    }

}
