//
//  ActionViewController.swift
//  SkynetSave
//
//  Created by Wojciech Mandrysz on 01/03/2020.
//  Copyright © 2020 Wojciech Mandrysz. All rights reserved.
//

import UIKit
import MobileCoreServices

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
        vc.preferredContentSize = CGSize(width: 40,height: 40)
        ActivityIndicatorData.activityIndicator.color = UIColor.white
        ActivityIndicatorData.activityIndicator.startAnimating()
        vc.view.addSubview(ActivityIndicatorData.activityIndicator)
        self.setValue(vc, forKey: "contentViewController")
    }

    func dismissActivityIndicator() {
        ActivityIndicatorData.activityIndicator.stopAnimating()
        ActivityIndicatorData.activityIndicator.removeFromSuperview()
//        self.dismiss(animated: false)
    }
}
class ActionViewController: UIViewController {

//    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var files: [URL] = []
    override func viewDidLoad() {
        super.viewDidLoad()
                
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            
            for provider in item.attachments! {
               
                if provider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {                                        
                    provider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { (imageURL, error) in
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
        self.extensionContext?.cancelRequest(withError: ErrorType.canceled)
    }
    
    @IBAction func save() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        if let url = files.first, let data = try? Data(contentsOf: url) {
//            let alert = UIAlertController(title: "Uploading..", message: "", preferredStyle: .alert)
//            alert.addActivityIndicator()
//            let action = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
//                    self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
//            });
//            alert.addAction(action)
//            self.show(alert, sender: nil)
            
            let _ = Skynet().upload(data: data, filename: url.lastPathComponent) { (success, skylink) in
                if success {
                    print("YEAH \(skylink)")
//                    alert.dismiss(animated: false) {
//                        let alert = UIAlertController(title: "Ready!", message: "", preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "Copy skylink", style: .default, handler: { (action) in
//                            let pasteboard = UIPasteboard.general
//                            pasteboard.string = Skynet().portal + skylink
//                                self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
//                        }))
//
//                        self.show(alert, sender: nil)
//                    }
                    
//                    self.present(alert, animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
                }
                else {
//                    self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
                }
            }
            self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
        }
            
        
    }

}

extension ActionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Reuse")
        cell.textLabel?.text = files[indexPath.row].lastPathComponent
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Selected files" : ""
    }
}
