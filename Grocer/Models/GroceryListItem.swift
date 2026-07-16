//
//  GroceryListItem.swift
//  Grocer
//
//  Created by Emil on 6/26/26.
//

import Foundation

struct GroceryListItem : Identifiable, Equatable{
    let id : String
    let item : Product
    var quantity : Int
    
    init(product: Product, quantity: Int = 1) {
        self.id = product.id
        self.item = product
        self.quantity = quantity
    }
    
}
