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
    @IBOutlet var currentPortal: UILabel!
    
    var files: [URL] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPortal.text = Manager.currentPortal.host
        for item in extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! {
                if provider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                    provider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { imageURL, _ in
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
        return files.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Reuse")
        cell.textLabel?.text = files[indexPath.row].lastPathComponent
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Selected files" : ""
    }
}
