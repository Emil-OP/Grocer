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
        case id
        case quantity = "amount"
        case name
        case price
        case measurement
        case measurementDescription
        case supermarketName = "supermarket"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.quantity = try container.decode(Int.self, forKey: .quantity)

        self.item = Product(
            id: try container.decode(String.self, forKey: .id),
            productName: try container.decode(String.self, forKey: .name),
            price: try container.decode(Double.self, forKey: .price),
            measurementDescription: try container.decode(String.self, forKey: .measurementDescription),
            measurement: try container.decode(Double.self, forKey: .measurement),
            supermarketName: try container.decode(String.self,forKey: .supermarketName),
            imageURL: ""
        )
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
