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

class EditItemFormViewController : FormViewController {
    
    var item : InventoryItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        navigationItem.title = "Edit Item"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(handleUpdate))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
        setupForm()
    }
    
    private func setupForm() {
        guard let item = item else {
            self.showMessage(with: "Error", message: "No item was passed to edit.")
            return
        }
        
        form +++ Section("General Information")
            <<< TextRow(){ row in
                row.title = "Name"
                row.value = item.name
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
                $0.value = (item.price)
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
                $0.value = item.quantity
                $0.tag = "quantity"
                $0.cell.stepper.minimumValue = 1
                $0.cell.stepper.maximumValue = 100
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChangeAfterBlurred
            }
            
            +++ Section("Optional Information")
            <<< ImageRow() { row in
                row.title = "Tap to change picture"
                row.sourceTypes = [.All]
                row.tag = "image"
                
                row.clearAction = .yes(style: UIAlertAction.Style.destructive)
            }
            <<< DateRow(){
                $0.title = "Date Purchased"
                $0.value = Date(timeIntervalSince1970: item.date_purchased ?? 0.0)
                $0.tag = "date_purchased"
            }
            
            <<< IntRow(){
                $0.title = "SKU"
                $0.value = item.sku ?? 0
                $0.tag = "sku"
            }
            
            <<< TextAreaRow() {
                $0.title = "Notes"
                $0.tag = "notes"
                $0.value = item.notes ?? "Enter notes here..."
            }
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleUpdate() {
        guard let itemID = item?.id else {
            self.showMessage(with: "Error", message: "Item did not load successfully from DB.")
            return
        }
        print("Updating item in DB...")
        let errors = form.validate() as [ValidationError]
        if errors.count > 0 {
            self.showMessage(with: "Error", message: "There are required fields that you have left blank. Please make sure to fill all required fields.")
            return
        }
        
        let values = form.values()
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
        
        
        let inventoryItem = InventoryItem(id: nil, name: name, price: price, quantity: quantity)
        
        if let image = values["image"] as? UIImage {
            guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
            
            guard let imageData = image.jpegData(compressionQuality: 0.25) else { return }
            let uuid = UUID().uuidString
            let storageRef = Storage.storage().reference().child("images").child(uid).child(uuid)
            inventoryItem.picture = uuid
            DispatchQueue.main.async {
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
        
        let jsonEncoder = JSONEncoder()
        do {
            guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
            let jsonData = try jsonEncoder.encode(inventoryItem)
            guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else { return }
            let dictionary = convertToDictionary(text: json)
            let dbRef = Database.database().reference()
            dbRef.child("inventories").child(uid).child(itemID).setValue(dictionary) { (error, _) in
                if let error = error {
                    self.showMessage(with: "Error", message: error.localizedDescription)
                    return
                }
                
                self.dismiss(animated: true, completion: nil)
            }
        } catch {
            self.showMessage(with: "Error", message: error.localizedDescription)
            return
        }
    }
    
}
