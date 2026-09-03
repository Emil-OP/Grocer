//
//  GroceryListItem.swift
//  Grocer
//
//  Created by Emil on 6/26/26.
//

import Foundation

struct GroceryListItem: Decodable, Identifiable, Equatable {
    let id = UUID()
    var quantity: Int
    let item: Product
    var parentLists: [UUID:Int] = [:]

    enum CodingKeys: String, CodingKey {
        case item
        case quantity = "amount"
        case parentID = "gl_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.quantity = try container.decode(Int.self, forKey: .quantity)
        self.item = try container.decode(Product.self,forKey: .item)
        self.parentLists[try container.decode(UUID.self,forKey: .parentID)] = try container.decode(Int.self, forKey: .quantity)
    }

    init(product: Product, quantity: Int = 1,parentLists: [UUID:Int]) {
        self.item = product
        self.quantity = quantity
        self.parentLists = self.parentLists.merging(parentLists){(_, new) in new}
    }
    
    mutating func addParent(withID glID: UUID){
        self.parentLists[glID] = quantity
    }
    
    
    //TODO: Add removal in GroceryListService.swift
    mutating func removeParent(withID glID: UUID){
        self.parentLists.removeValue(forKey: glID)
    }
}
