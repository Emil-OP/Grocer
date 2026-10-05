//
//  MockExtensions.swift
//  Grocer
//
//  Created by Emil on 10/2/26.
//

import Foundation

@testable import Grocer

extension GroceryList {
    static func mock(
        id: UUID = UUID(),
        name: String = "MockList \(String(Int.random(in: 1...100)))",
        itemsAmount: Int = 0,
        purchasedItemsAmount: Int = 0
    ) -> GroceryList {
        let items = (0..<itemsAmount).map { _ in
            GroceryListItem.mock(parentId: id)
        }
        let purchasedItems = (0..<purchasedItemsAmount).map { _ in
            GroceryListItem.mock(parentId: id)
        }
        return GroceryList(
            id: id,
            name: name,
            items: items,
            purchasedItems: purchasedItems
        )
    }
}

extension GroceryListItem {
    static func mock(itemId: UUID = UUID(), parentId: UUID) -> GroceryListItem {
        GroceryListItem(
            id: itemId,
            product: Product.mock(),
            parentLists: [parentId : Int.random(in: 1...10)]
        )
    }
}

extension Product {
    static func mock() -> Product {
        Product(
            id: UUID(),
            productName: "Test Product",
            price: Double.random(in: 1...10),
            measurementDescription: "Test kg",
            measurement: Double.random(in: 1...10),
            supermarketName: "Test Supermarket",
            imageURL: ""
        )
    }
}
