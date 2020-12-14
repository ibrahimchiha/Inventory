//
//  Item.swift
//  Intentory+
//
//  Created by Ibrahim Chiha on 12/13/20.
//

import Foundation


class InventoryItem : Codable {
    
    var id: String?
    
    var name: String
    var price: Double
    var quantity: Double
    
    var picture: String?
    var date_purchased: Double?
    var sku: Int?
    var notes: String?
    
    init(id: String?, name: String, price: Double, quantity: Double) {
        self.id = id
        self.name = name
        self.price = price
        self.quantity = quantity
    }
    
    init(id: String?, name: String, price: Double, quantity: Double, picture: String?, date_purchased: Double?, sku: Int?, notes: String?) {
        self.id = id
        self.name = name
        self.price = price
        self.quantity = quantity
        self.picture = picture
        self.date_purchased = date_purchased
        self.sku = sku
        self.notes = notes
    }
    
    
}
