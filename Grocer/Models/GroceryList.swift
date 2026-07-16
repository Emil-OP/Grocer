//
//  GroceryList.swift
//  Grocer
//
//  Created by Emil on 6/24/26.
//

import Foundation

struct GroceryList : Identifiable, Equatable {
    let id = UUID()
    var name : String
    let items : [GroceryListItem]
    let purchasedItems : [GroceryListItem]
    var isActive : Bool = true
    //Do I need a creatorId in order to work with the databse or would it be more secure to do it within the database?
}
