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
import SwiftUI

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
    var zipFilename = "Archive"
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
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    @IBAction func cancel() {
        extensionContext?.cancelRequest(withError: ErrorType.canceled)
    }

    @IBAction func save() {
        if zipIt {
            let tmpDirURL = FileManager.default.temporaryDirectory
            let zipFilePath = tmpDirURL.appendingPathComponent(zipFilename + ".zip")
            try? Zip.zipFiles(paths: files, zipFilePath: zipFilePath, password: nil, progress: { (progress) -> Void in
                print(progress)
            })
            if let data = try? Data(contentsOf: zipFilePath) {
                Manager.setExpectedDownloads(number: 1)
                Skynet(portal: Manager.currentPortal).uploadInBackground(data: data, filename: zipFilePath.lastPathComponent)
            }
        } else {
            Manager.setExpectedDownloads(number: files.count)
            for url in files {
                if let data = try? Data(contentsOf: url) {
                    Skynet(portal: Manager.currentPortal).uploadInBackground(data: data, filename: url.lastPathComponent)
                }
            }
        }

        extensionContext!.completeRequest(returningItems: extensionContext!.inputItems, completionHandler: nil)
    }
}

extension ActionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            let h = HostingController(rootView: PortalsView())
            h.onComplete = {
                self.tableView.reloadData()
            }
            self.show(h, sender: nil)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return zipIt ? 2 : 1
        case 2:
            return files.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Reuse")
        if indexPath.section == 0 {
            let portal = Manager.currentPortal
            cell.textLabel?.text = portal.name + " (\(portal.host))"
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Zip selected files"
                let zipSwitch = UISwitch(frame: CGRect.zero)
                zipSwitch.addTarget(self, action: #selector(toggleZip(sw:)), for: UIControl.Event.valueChanged)
                zipSwitch.isOn = self.zipIt
                cell.accessoryView = zipSwitch
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Zip filename"
                let field = UITextField(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
                field.text = zipFilename
                field.clearButtonMode = UITextField.ViewMode.whileEditing
                field.returnKeyType = UIReturnKeyType.done
                field.delegate = self
                field.textAlignment = .right
                cell.accessoryView = field
            }
        } else {
            cell.textLabel?.text = files[indexPath.row].lastPathComponent
        }
        return cell
    }

    
    
    @objc func toggleZip(sw: UISwitch) {
        self.zipIt = sw.isOn
        self.tableView.reloadData()
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
extension ActionViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
           let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            self.zipFilename = updatedText
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let f = textField.text {
            self.zipFilename = f
        }
        textField.resignFirstResponder()
        return true
    }
}

class HostingController: UIHostingController<PortalsView> {
    var onComplete: (() -> ())?
    override func viewWillDisappear(_ animated: Bool) {
        self.onComplete?()
    }
    
}
