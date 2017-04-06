//
//  ServerViewController.swift
//  Parse Dashboard for iOS
//
//  Created by Nathan Tannar on 2/28/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit
import NTComponents
import CoreData
import QuartzCore

class ServerViewController: UITableViewController {
    
    var servers: [ParseServer] = []
    var indexPathForSelectedRow: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "Logo")?.scale(to: 40))
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 10
        tableView.backgroundColor = Color(r: 30, g: 59, b: 77)
        tableView.separatorStyle = .none
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addServer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Info"), style: .plain, target: self, action: #selector(showAppInfo))
        navigationController?.navigationBar.setDefaultShadow()
        
        getServers()
    }
    
    func getServers() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<ParseServer> = ParseServer.fetchRequest()
        do {
            servers = try context.fetch(request)
        } catch {
            Toast(text: "Could not load servers from Core Data").show(duration: 1.0)
        }
        tableView.reloadData()
    }
    
    func showAppInfo() {
        let navVC = NTNavigationController(rootViewController: AppInfoViewController())
        navVC.modalPresentationStyle = .custom
        navVC.transitioningDelegate = self
        navVC.view.layer.cornerRadius = 12
        navVC.view.clipsToBounds = true
        present(navVC, animated: true, completion: nil)
    }

    // MARK: - User Actions
    
    func addServer() {
        let alertController = UIAlertController(title: "Add Server", message: nil, preferredStyle: .alert)
        alertController.view.tintColor = Color.Defaults.tint
        
        let saveAction = UIAlertAction(title: "Add", style: .default, handler: {
            alert -> Void in
        
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let parseServerObject = NSManagedObject(entity: ParseServer.entity(), insertInto: context)
            parseServerObject.setValue(alertController.textFields![0].text, forKey: "name")
            parseServerObject.setValue(alertController.textFields![1].text, forKey: "applicationId")
            parseServerObject.setValue(alertController.textFields![2].text, forKey: "masterKey")
            parseServerObject.setValue(alertController.textFields![3].text, forKey: "serverUrl")
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            self.servers.append(parseServerObject as! ParseServer)
            self.tableView.insertRows(at: [IndexPath(row: self.servers.count - 1, section: 0)], with: .fade)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "App Name"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Application ID"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Master Key"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Server URL"
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func editServer(_ indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Configuration", message: "Edit", preferredStyle: .alert)
        alertController.view.tintColor = Color.Defaults.tint
        
        let parseServerObject = self.servers[indexPath.row]
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            
            parseServerObject.setValue(alertController.textFields![0].text, forKey: "name")
            parseServerObject.setValue(alertController.textFields![1].text, forKey: "applicationId")
            parseServerObject.setValue(alertController.textFields![2].text, forKey: "masterKey")
            parseServerObject.setValue(alertController.textFields![3].text, forKey: "serverUrl")
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            self.tableView.reloadRows(at: [indexPath], with: .none)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "App Name"
            textField.text = parseServerObject.name
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Application ID"
            textField.text = parseServerObject.applicationId
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Master Key"
            textField.text = parseServerObject.masterKey
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "http://<url>:<port>/<parse mount>"
            textField.text = parseServerObject.serverUrl
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func toggleSwitch(sender: UISwitch) {
        
    }
    
    // MARK: - UITableViewDatasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ServerCell()
        cell.server = servers[indexPath.row]
        return cell
  
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let server = servers[indexPath.row]
        Parse.initialize(with: server)
        let vc = SchemaViewController(server: server)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .default, title: " Edit ", handler: { action, indexpath in
            
            let actionSheetController: UIAlertController = UIAlertController(title: nil, message: "Edit Server", preferredStyle: .actionSheet)
            actionSheetController.view.tintColor = Color.Defaults.tint
            actionSheetController.view.backgroundColor = .white
            
            let configAction: UIAlertAction = UIAlertAction(title: "Configuration", style: .default) { action -> Void in
                self.editServer(indexPath)
            }
            actionSheetController.addAction(configAction)
            
            let iconAction: UIAlertAction = UIAlertAction(title: "Icon", style: .default) { action -> Void in
                self.indexPathForSelectedRow = indexPath
                self.presentImagePicker()
            }
            actionSheetController.addAction(iconAction)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
            actionSheetController.addAction(cancelAction)
            
            self.present(actionSheetController, animated: true, completion: nil)
        })
        editAction.backgroundColor = Color.Defaults.tint
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { action, indexpath in
            
            let alertController = UIAlertController(title: "Are you sure?", message: "This cannot be undone", preferredStyle: .alert)
            alertController.view.tintColor = Color.Defaults.tint
            
            let saveAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
                alert -> Void in
                
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                context.delete(self.servers[indexPath.row])
                do {
                    try context.save()
                } catch {
                    Toast(text: "Could not delete server from core data").show(duration: 2.0)
                }
                
                self.servers.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(saveAction)
            self.present(alertController, animated: true, completion: nil)
        })
        
        return [deleteAction, editAction]
    }
}

extension ServerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: UIImagePickerControllerDelegate
    
    func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.view.tintColor = Color.Defaults.tint
        picker.navigationController?.navigationBar.tintColor = Color.Defaults.navigationBarTint
        picker.navigationController?.navigationBar.barTintColor = Color.Defaults.navigationBarBackground
        picker.navigationController?.navigationBar.isTranslucent = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let indexPath = indexPathForSelectedRow else { return }
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let imageData = UIImageJPEGRepresentation(image, 1)
            self.servers[indexPath.row].setValue(imageData, forKey: "icon")
            do {
                try context.save()
            } catch {
                Toast(text: "Could not save icon to core data").show(duration: 2.0)
            }
            picker.dismiss(animated: true, completion: {
                self.tableView.reloadRows(at: [indexPath], with: .none)
            })
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ServerViewController: UIViewControllerTransitioningDelegate {
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return PreviewPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

class PreviewPresentationController: UIPresentationController {
    
    // Custom frame for presentation of the view controller
    override var frameOfPresentedViewInContainerView : CGRect {
        let containerFrame = self.containerView!.frame
        let rect = CGRect(x: 12, y: containerFrame.height / 8, width: containerFrame.width - 24, height: containerFrame.height * 3 / 4)
        return rect
    }
}