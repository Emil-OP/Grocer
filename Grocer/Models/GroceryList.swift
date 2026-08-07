//
//  GroceryList.swift
//  Grocer
//
//  Created by Emil on 6/24/26.
//

import Foundation

@Observable  class GroceryList : Decodable,Identifiable, Equatable {
    let id: UUID
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
    
    init(
        id: UUID = UUID(),
        name: String,
        items: [GroceryListItem],
        purchasedItems: [GroceryListItem],
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.items = items
        self.purchasedItems = purchasedItems
        self.isActive = isActive
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.items = try container.decode([GroceryListItem].self, forKey: .items)
        self.purchasedItems = try container.decode([GroceryListItem].self, forKey: .purchasedItems)
    }
    
    static func == (lhs: GroceryList, rhs: GroceryList) -> Bool {
            lhs.id == rhs.id
        }
    
    
}
