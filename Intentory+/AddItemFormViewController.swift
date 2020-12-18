//
//  AddItemFormViewController.swift
//  Intentory+
//
//  Created by Ibrahim Chiha on 11/14/20.
//

import UIKit
import Eureka
import ImageRow
import FirebaseStorage
import FirebaseDatabase

class AddItemFormViewController : FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        navigationItem.title = "Add Item"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(handleUpdate))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
        setupForm()
    }
    
    private func setupForm() {
        form +++ Section("Required Information")
            <<< TextRow(){ row in
                row.title = "Name"
                row.placeholder = "Item name"
                row.tag = "name"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChangeAfterBlurred
            }
            .cellUpdate({ (cell, row) in
                if !row.isValid {
                    cell.titleLabel?.textColor = .systemRed
                }
            })
            <<< DecimalRow() {
                $0.title = "Price"
                $0.placeholder = "8.00"
                $0.tag = "price"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChangeAfterBlurred
            }
            .cellUpdate({ (cell, row) in
                if !row.isValid {
                    cell.titleLabel?.textColor = .systemRed
                }
            })
            
            <<< StepperRow() {
                $0.title = "Quantity"
                $0.value = 1
                $0.tag = "quantity"
                $0.cell.stepper.minimumValue = 1
                $0.cell.stepper.maximumValue = 100
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChangeAfterBlurred
            }
            
            +++ Section("Optional Information")
            <<< ImageRow() { row in
                row.title = "Tap to add a picture"
                row.sourceTypes = [.All]
                row.tag = "image"
                
                row.clearAction = .yes(style: UIAlertAction.Style.destructive)
            }
            <<< DateRow(){
                $0.title = "Date Purchased"
                $0.value = Date()
                $0.tag = "date_purchased"
            }
            
            <<< IntRow(){
                $0.title = "SKU"
                $0.placeholder = "123456789"
                $0.tag = "sku"
            }
            
            <<< TextAreaRow() {
                $0.title = "Notes"
                $0.tag = "notes"
                $0.placeholder = "Enter notes here..."
            }
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Handles any updates the item has
    @objc func handleUpdate() {
        print("Saving item to DB...")
        
        // Validates the form
        let errors = form.validate() as [ValidationError]
        if errors.count > 0 {
            self.showMessage(with: "Error", message: "There are required fields that you have left blank. Please make sure to fill all required fields.")
            return
        }
        
        // Get values from form
        let values = form.values()
        // parse name parameter etc...
        guard let name = values["name"] as? String else {
            self.showMessage(with: "Hmm...", message: "The name field seems to be left blank. Please make sure to add a name to your item.")
            return
        }
        
        guard let price = values["price"] as? Double else {
            self.showMessage(with: "Hmm...", message: "The price field seems to be left blank. Please make sure to add a price to your item.")
            return
        }
        
        guard let quantity = values["quantity"] as? Double else {
            self.showMessage(with: "Hmm...", message: "The quantity field seems to be left blank. Please make sure to add how many items you have.")
            return
        }
        
        
        // Create the item
        let inventoryItem = InventoryItem(id: nil, name: name, price: price, quantity: quantity)
        
        // Load it's image
        if let image = values["image"] as? UIImage {
            guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
            
            guard let imageData = image.jpegData(compressionQuality: 0.25) else { return }
            let uuid = UUID().uuidString
            let storageRef = Storage.storage().reference().child("images").child(uid).child(uuid)
            inventoryItem.picture = uuid
            DispatchQueue.main.async {
                // Upload image to Firebase Storage
                let uploadTask = storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                    guard let _ = metadata else {
                        self.showMessage(with: "Error", message: "An error occured while fetching the metadata. Please try again.")
                        return
                    }
                    
                    
                }
                uploadTask.resume()
            }
            // Upload the file to the path "images/{uid}/{uuid}.jpg"
            
        }
        
        if let date_purchased = values["date_purchased"] as? Date {
            
            inventoryItem.date_purchased = date_purchased.timeIntervalSince1970

        }
        
        if let sku = values["sku"] as? Int {
            inventoryItem.sku = sku
        }
        
        if let notes = values["notes"] as? String {
            inventoryItem.notes = notes
        }
        
        // Converting InventoryItem to json to send to DB
        let jsonEncoder = JSONEncoder()
        do {
            guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
            let jsonData = try jsonEncoder.encode(inventoryItem)
            guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else { return }
            let dictionary = convertToDictionary(text: json)
            let dbRef = Database.database().reference()
            dbRef.child("inventories").child(uid).childByAutoId().setValue(dictionary) { (error, _) in
                //Error updating item
                if let error = error {
                    self.showMessage(with: "Error", message: error.localizedDescription)
                    return
                }
                
                // Dismiss the item edit view
                self.dismiss(animated: true, completion: nil)
            }
        } catch {
            self.showMessage(with: "Error", message: error.localizedDescription)
            return
        }
    }
    
}
