//
//  GroceryListTest.swift
//  GrocerTests
//
//  Created by Emil on 10/1/26.
//

import Foundation
import Testing

@testable import Grocer

struct GroceryListTest {

    func makeGroceryList(itemsAmount: Int, purchasedItemsAmount: Int) -> GroceryList {
        let id = UUID()
        let items = (0..<itemsAmount).map { _ in makeItem(id: id) }
        let purchasedItems = (0..<purchasedItemsAmount).map { _ in
            makeItem(id: id)
        }

        return GroceryList(
            id: id,
            name: "List \(String(Int.random(in: 1...100)))",
            items: items,
            purchasedItems: purchasedItems
        )
    }

    func makeItem(id: UUID) -> GroceryListItem {
        GroceryListItem(
            product: makeProduct(),
            parentLists: [id: Int.random(in: 1...10)]
        )
    }

    func makeProduct() -> Product {
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

    @Test("Grocery list completion percentage", arguments: [
                                                    (3, 2, 40.0),
                                                    (0, 5, 100.0),
                                                    (5, 0, 0.0),
                                                    (1, 1, 50.0),
                                                    (10, 90, 90.0),
                                                ]
    ) func percentage_for_purchased_items(itemsAmount: Int, purchasedItemsAmount: Int, expected: Double) async throws {
        //ARRANGE
        let list = makeGroceryList(itemsAmount: itemsAmount, purchasedItemsAmount: purchasedItemsAmount)
        //ACT
        let percentage = await list.completedPercentage
        //ASSERT
        #expect(abs(percentage-expected) <= 0.01)
    }

}
