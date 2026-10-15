//
//  GroceryListItem.swift
//  Grocer
//
//  Created by Emil on 6/26/26.
//

import Foundation

struct GroceryListItem: Decodable, Identifiable, Equatable {
    let id: UUID
    var amount: Int
    let item: Product
    var parentLists: [UUID:Int] = [:]

    enum CodingKeys: String, CodingKey {
        case id = "gli_id"
        case item
        case amount
        case parentID = "gl_id"
    } 

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.amount = try container.decode(Int.self, forKey: .amount)
        self.item = try container.decode(Product.self,forKey: .item)
        self.parentLists[try container.decode(UUID.self,forKey: .parentID)] = try container.decode(Int.self, forKey: .amount)
    }

    init(id: UUID = UUID(),product: Product, amount: Int = 1,parentLists: [UUID:Int]) {
        self.id = id
        self.item = product
        self.amount = amount
        self.parentLists = self.parentLists.merging(parentLists){(_, new) in new}
    }
    
    mutating func addParent(withID glID: UUID){
        self.parentLists[glID] = amount
    }
    
    //TODO: Add removal in GroceryListService.swift
    mutating func removeParent(withID glID: UUID){
        self.parentLists.removeValue(forKey: glID)
    }
}
