//
//  GroceryListRepositoryTest.swift
//  GrocerTests
//
//  Created by Emil on 10/1/26.
//

import Foundation
import Testing

@testable import Grocer

//MARK: Mocks

final class MockGroceryListService: GroceryListServiceProtocol {
    func fetchGroceryLists() async throws -> [GroceryList] {
        return [GroceryList.mock()]
    }
    func createGroceryList(groceryListName: String) async throws -> GroceryList
    {
        return GroceryList.mock(name: groceryListName)
    }
    func insertGroceryListItem(item: GroceryListItem, into listId: UUID)
        async throws -> GroceryList
    {
        let list = GroceryList.mock(id: listId)
        list.items.append(item)
        return list
    }
    func toggleItemStatus(
        for glItemID: UUID,
        inListWithID listId: UUID,
        isPurchased: Bool
    ) async throws -> GroceryList {
        let list = GroceryList.mock()
        if isPurchased {
            list.purchasedItems.append(
                GroceryListItem.mock(itemId: glItemID, parentId: listId)
            )
        } else {
            list.items.append(
                GroceryListItem.mock(itemId: glItemID, parentId: listId)
            )
        }

        return list
    }
    func fetchGroceryList(byID listId: UUID) async throws -> GroceryList {
        return GroceryList.mock()
    }
}

@Suite("GroceryListRepo")
@MainActor
struct GroceryListRepositoryTest {

    @Test("Fetching grocery lists adds them to the dictionary")
    func grocery_lists_cache() async throws {
        let repo = GroceryListRepository(
            groceryListService: MockGroceryListService()
        )
        await repo.loadGroceryLists()
        #expect(!repo.groceryLists.isEmpty)
        #expect(!repo.groceryListsArray.isEmpty)
    }

    @Test("Grocery list cached and created with correct name")
    func grocery_list_created_correctly() async throws {
        let repo = GroceryListRepository(
            groceryListService: MockGroceryListService()
        )
        let listName = "TestList"
        let id = try #require(
            await repo.createGroceryList(groceryListName: listName)
        )
        let list = try #require(repo.groceryLists[id])

        #expect(list.name == listName)
    }

    @Test("Inserting item populate correct GroceryList")
    func item_inserted_in_grocery_list_populates_list() async throws {
        let repo = GroceryListRepository(
            groceryListService: MockGroceryListService()
        )
        let id = try #require(
            await repo.createGroceryList(groceryListName: "TestList")
        )
        let item = GroceryListItem.mock(parentId: id)
        await repo.addItemToGroceryList(item: item, into: id)
        let updatedList = try #require(repo.groceryLists[id])
        #expect(updatedList.items == [item])
    }

    //TODO: Test inserting an item with a UUID that does not correspond to any existing lists?

    @Test(
        "Item is moved to corresponding list when toggled",
        arguments: [true, false]
    )
    func item_correctly_moved_when_toggled(isPurchased: Bool) async throws {
        let repo = GroceryListRepository(
            groceryListService: MockGroceryListService()
        )
        let glId = try #require(
            await repo.createGroceryList(groceryListName: "TestList")
        )
        let item = GroceryListItem.mock(parentId: glId)
        if isPurchased {
            repo.groceryLists[glId]?.purchasedItems.append(item)
        } else {
            repo.groceryLists[glId]?.items.append(item)
        }
        await repo.toggleItemAsPurchased(
            for: item.id,
            inList: glId,
            isPurchased: isPurchased
        )

        let list = try #require(repo.groceryLists[glId])

        #expect(list.items.contains(item) != isPurchased)
        #expect(list.purchasedItems.contains(item) == isPurchased)

    }

    @Test("Grocery list active state toggled")
    func list_correctly_toggled_active_state() async throws {
        let repo = GroceryListRepository(
            groceryListService: MockGroceryListService()
        )
        let glId = try #require(
            await repo.createGroceryList(groceryListName: "TestList")
        )
        let list = try #require(await repo.groceryLists[glId])
        #expect(list.isActive == true, "Initial state should be active(true)")
        repo.toggleListActiveState(for: glId)

        #expect(list.isActive == false, "List should be inactive(false) after toggle")
    }
}
