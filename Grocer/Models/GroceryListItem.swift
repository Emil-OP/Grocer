//
//  GroceryListItem.swift
//  Grocer
//
//  Created by Emil on 6/26/26.
//

import Foundation

struct GroceryListItem: Decodable, Identifiable, Equatable {
    let id: String
    var quantity: Int
    let item: Product

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
        self.id = try container.decode(String.self, forKey: .id)
        self.quantity = try container.decode(Int.self, forKey: .quantity)

        self.item = Product(
            id: self.id,
            productName: try container.decode(String.self, forKey: .name),
            price: try container.decode(Double.self, forKey: .price),
            measurementDescription: try container.decode(String.self, forKey: .measurementDescription),
            measurement: try container.decode(Double.self, forKey: .measurement),
            supermarketName: try container.decode(String.self,forKey: .supermarketName),
            imageURL: ""
        )

    }

    init(product: Product, quantity: Int = 1) {
        self.id = product.id
        self.item = product
        self.quantity = quantity
    }
}
