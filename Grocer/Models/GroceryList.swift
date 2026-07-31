//
//  GroceryList.swift
//  Grocer
//
//  Created by Emil on 6/24/26.
//

import Foundation

struct GroceryList : Decodable,Identifiable, Equatable {
    var id: UUID
    var name : String
    let items : [GroceryListItem]
    let purchasedItems : [GroceryListItem]
    var isActive : Bool = true
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case items
        case purchasedItems = "purchased_items"
    }
}
