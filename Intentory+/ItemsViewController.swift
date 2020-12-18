//
//  ViewController.swift
//  Intentory+
//
//  Created by Ibrahim Chiha on 11/14/20.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private final let itemReuseIdentifier = "itemCell"
    private final let createItemReuseIdentifier = "createCell"
    
    var items : [InventoryItem] = []
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(AddItemTableViewCell.self, forCellReuseIdentifier: createItemReuseIdentifier)
        tableView.register(ItemTableViewCell.self, forCellReuseIdentifier: itemReuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
   
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // Checks if user is authenticated, if not redirect to register view controller
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser == nil {
            let vc = RegisterViewController()
            // Disables Modal Dismiss functionality
            vc.isModalInPresentation = true
            self.present(vc, animated: true, completion: nil)
            return
        }
        loadItems()
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    // Loads the inventory items from Firebase Database.
    func loadItems() {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let dbRef = Database.database().reference()
        
        dbRef.child("inventories").child(uid).observe(.value) { (snapshot) in
            self.items.removeAll()
            guard let value = snapshot.value as? [String:Any] else { return }
            
            // Looping over all items that were received from our call
            for key in value.keys {
                // Error
                guard let itemJSON = value[key] as? [String : Any] else {
                    self.showMessage(with: "Error", message: "There was an error with the response.")
                    return
                }
                
                // Making sure all the required parameters were received
                guard let name = itemJSON["name"] as? String, let price = itemJSON["price"] as? Double, let quantity = itemJSON["quantity"] as? Double else {
                    self.showMessage(with: "Error", message: "Some required fields were left blank. Cannot retrieve them.")
                    return
                }
                
                // Creating the item
                let item = InventoryItem(id: key, name: name, price: price, quantity: quantity)
                
                //Adding optional parameters if they exist
                if let date_purchased = itemJSON["date_purchased"] as? Double {
                    item.date_purchased = date_purchased
                }
                
                if let picture = itemJSON["picture"] as? String {
                    item.picture = picture
                }
                
                if let sku = itemJSON["sku"] as? Int {
                    item.sku = sku
                }
                
                if let notes = itemJSON["notes"] as? String {
                    item.notes = notes
                }
                
                // Appending the item to the list of items
                self.items.append(item)
            }
            
            // Refreshing the tableview to show changes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    private func setupView() {
        view.addSubview(tableView)
        navigationItem.title = "Items"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(handleLogout))
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        tableView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return items.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: createItemReuseIdentifier, for: indexPath) as! AddItemTableViewCell
            cell.createNewButton.addTarget(self, action: #selector(handleCreateItem), for: .touchUpInside)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: itemReuseIdentifier, for: indexPath) as! ItemTableViewCell
            cell.item = items[indexPath.row]
            cell.seeMoreButton.tag = indexPath.row
            cell.seeMoreButton.addTarget(self, action: #selector(handleSeeMore(sender:)), for: .touchUpInside)
            return cell
        }
    }
    
    @objc func handleCreateItem() {
        let addItemFormVC = AddItemFormViewController()
        let navigationVC = UINavigationController(rootViewController: addItemFormVC)
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    
    @objc func handleSeeMore(sender: UIButton) {
        let item = items[sender.tag]
        let actionSheet = UIAlertController(title: item.name, message: "\(item.quantity) in stock", preferredStyle: .actionSheet)
        
        // Cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        // Delete
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            let row = sender.tag
            let item = self.items[row]
            guard let id = item.id, let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
                print("error while retrieving ID of item")
                return
            }
            
            let dbRef = Database.database().reference()
            dbRef.child("inventories").child(uid).child(id).removeValue()
            self.items.remove(at: sender.tag)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        })
        actionSheet.addAction(deleteAction)
        
        // Edit
        let editAction = UIAlertAction(title: "Edit Item", style: .default, handler: { (_) in
            let row = sender.tag
            let item = self.items[row]
            let vc = EditItemFormViewController()
            vc.item = item
            let navVC = UINavigationController(rootViewController: vc)
            self.present(navVC, animated: true, completion: nil)
            
        })
        actionSheet.addAction(editAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "All Items"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 65
        }
        
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        let editVC = EditItemFormViewController()
        editVC.item = item
        let navVC = UINavigationController(rootViewController: editVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
}

