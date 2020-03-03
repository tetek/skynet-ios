//
//  ActionViewController.swift
//  SkynetSave
//
//  Created by Wojciech Mandrysz on 01/03/2020.
//  Copyright © 2020 Wojciech Mandrysz. All rights reserved.
//

import MobileCoreServices
import UIKit
import Zip

enum ErrorType: Error {
    case canceled
    case shit(Character)
}

extension UIAlertController {
    private struct ActivityIndicatorData {
        static var activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    }

    func addActivityIndicator() {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 40, height: 40)
        ActivityIndicatorData.activityIndicator.color = UIColor.white
        ActivityIndicatorData.activityIndicator.startAnimating()
        vc.view.addSubview(ActivityIndicatorData.activityIndicator)
        setValue(vc, forKey: "contentViewController")
    }

    func dismissActivityIndicator() {
        ActivityIndicatorData.activityIndicator.stopAnimating()
        ActivityIndicatorData.activityIndicator.removeFromSuperview()
//        self.dismiss(animated: false)
    }
}

class ActionViewController: UIViewController {
//    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    var zipIt = false
    var files: [URL] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        for item in extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! {
                let types = [kUTTypeAudiovisualContent, kUTTypeImage, kUTTypePDF, kUTTypeJSON].map({ $0 as String })

                if let type = types.first(where: { provider.hasItemConformingToTypeIdentifier($0) }) {
                    provider.loadItem(forTypeIdentifier: type, options: nil, completionHandler: { imageURL, _ in
                        if let imageURL = imageURL as? URL {
                            self.files += [imageURL]
                        }

                        OperationQueue.main.addOperation {
                            self.zipIt = self.files.count > 1
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        }
    }

    @IBAction func cancel() {
        extensionContext?.cancelRequest(withError: ErrorType.canceled)
    }

    func zip() {
        let tmpDirURL = FileManager.default.temporaryDirectory
        let zipFilePath = tmpDirURL.appendingPathComponent("archive.zip")
        try? Zip.zipFiles(paths: files, zipFilePath: zipFilePath, password: "elo", progress: { (progress) -> Void in
            print(progress)
        })
    }

    @IBAction func save() {
        if zipIt {
            let tmpDirURL = FileManager.default.temporaryDirectory
            let zipFilePath = tmpDirURL.appendingPathComponent("skynetapp-upload.zip")
            try? Zip.zipFiles(paths: files, zipFilePath: zipFilePath, password: nil, progress: { (progress) -> Void in
                print(progress)
            })
            if let data = try? Data(contentsOf: zipFilePath) {
                Skynet(portal: Manager.currentPortal).uploadInBackground(data: data, filename: zipFilePath.lastPathComponent)
            }
        } else {
            for url in files {
                if let data = try? Data(contentsOf: url) {
                    Skynet(portal: Manager.currentPortal).uploadInBackground(data: data, filename: url.lastPathComponent)
                }
            }
        }

        extensionContext!.completeRequest(returningItems: extensionContext!.inputItems, completionHandler: nil)
    }
}

extension ActionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 || section == 1 ? 1 : files.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Reuse")
        if indexPath.section == 0 {
            let portal = Manager.currentPortal
            cell.textLabel?.text = portal.name + " (\(portal.host))"
        } else if indexPath.section == 1 {
            cell.textLabel?.text = "Zip selected files"
            let zipSwitch = UISwitch(frame: CGRect.zero)
            zipSwitch.addTarget(self, action: #selector(toggleZip(sw:)), for: UIControl.Event.valueChanged)
            zipSwitch.isOn = self.zipIt
            cell.accessoryView = zipSwitch
        } else {
            cell.textLabel?.text = files[indexPath.row].lastPathComponent
        }
        return cell
    }

    @objc func toggleZip(sw: UISwitch) {
        self.zipIt = sw.isOn
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Portal"
        case 1:
            return "Options"
        case 2:
            return "Selected files"
        default:
            return ""
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 2 {
            return "Downloading will begin in the background. You will be notified once upload is done. Open Skynet app to get history of uploads."
        }
        return nil
    }
}
