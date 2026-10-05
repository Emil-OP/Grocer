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

    @Test("Grocery list completion percentage", arguments: [
                                                    (3, 2, 40.0),
                                                    (0, 5, 100.0),
                                                    (5, 0, 0.0),
                                                    (1, 1, 50.0),
                                                    (10, 90, 90.0),
                                                ]
    ) func percentage_for_purchased_items(itemsAmount: Int, purchasedItemsAmount: Int, expected: Double) async throws {
        //ARRANGE
        let list = GroceryList.mock(itemsAmount: itemsAmount, purchasedItemsAmount: purchasedItemsAmount)
        //ACT
        let percentage = await list.completedPercentage
        //ASSERT
        #expect(abs(percentage-expected) <= 0.01)
    }

}
