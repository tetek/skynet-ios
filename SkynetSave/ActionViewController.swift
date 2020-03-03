//
//  ActionViewController.swift
//  SkynetSave
//
//  Created by Wojciech Mandrysz on 01/03/2020.
//  Copyright © 2020 Wojciech Mandrysz. All rights reserved.
//

import MobileCoreServices
import UIKit

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

    var files: [URL] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for item in extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! {
                let types = [kUTTypeAudiovisualContent as String, kUTTypeImage as String]
                
                if let type = types.first(where: {provider.hasItemConformingToTypeIdentifier($0)}) {
                    provider.loadItem(forTypeIdentifier: type, options: nil, completionHandler: { imageURL, _ in
                        if let imageURL = imageURL as? URL {
                            self.files += [imageURL]
                        }
                        OperationQueue.main.addOperation {
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

    @IBAction func save() {
        for url in files {
            if let data = try? Data(contentsOf: url) {
                Skynet(portal: Manager.currentPortal).uploadInBackground(data: data, filename: url.lastPathComponent)
            }
        }
        extensionContext!.completeRequest(returningItems: extensionContext!.inputItems, completionHandler: nil)
    }
}

extension ActionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : files.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Reuse")
        if indexPath.section == 0 {
            let portal = Manager.currentPortal
            cell.textLabel?.text = portal.name + " (\(portal.host))"
        } else {
            cell.textLabel?.text = files[indexPath.row].lastPathComponent
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Portal" : "Selected files"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return "Downloading will begin in the background. You will be notified once upload is done. Open Skynet app to get history of uploads."
        }
        return nil
    }
}
