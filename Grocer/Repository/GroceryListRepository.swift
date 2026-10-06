//
//  GroceryListRepository.swift
//  Grocer
//
//  Created by Emil on 7/31/26.
//

import Foundation

@Observable
class GroceryListRepository {
    private(set) var groceryLists: [UUID: GroceryList] = [:]
    private(set) var isLoading: Bool = false
    private let groceryListService: any GroceryListServiceProtocol
    private var error: String?
    var groceryListsArray: [GroceryList] {
        Array(groceryLists.values)
    }

    init(groceryListService: any GroceryListServiceProtocol = GroceryListService()) {
        self.groceryListService = groceryListService
    }

    func loadGroceryLists() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            groceryLists = try await groceryListService.fetchGroceryLists()
                .reduce(into: [UUID: GroceryList]()) { dict, list in
                    dict[list.id] = list
                }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func createGroceryList(groceryListName: String) async -> UUID? {
        do {
            let newList = try await groceryListService.createGroceryList(
                groceryListName: groceryListName
            )
            groceryLists[newList.id] = newList
            return newList.id
        } catch {
            print(
                "Failed to add new grocery list onto local repository: \(error.localizedDescription)"
            )
        }
        return nil
    }

    func addItemToGroceryList(item: GroceryListItem, into listWithID: UUID) async {
        do {
            let updatedList =
                try await groceryListService.insertGroceryListItem(
                    item: item,
                    into: listWithID
                )
            groceryLists[updatedList.id] = updatedList
        } catch {
            print(
                "Failed to insert item into grocery list: \(error.localizedDescription)"
            )
        }
    }

    func toggleItemAsPurchased(for glItemID: UUID, inList listID: UUID, isPurchased: Bool) async {
        do {
            let updatedList = try await groceryListService.toggleItemStatus(
                for: glItemID,
                inListWithID: listID,
                isPurchased: isPurchased
            )
            groceryLists[updatedList.id] = updatedList

        } catch {
            print("Failed to toggle item: \(error.localizedDescription)")
        }
    }

    func getGroceryListById(listID: UUID) async -> GroceryList? {
        if let list = groceryLists[listID] {
            return list
        }
        let fetchedList = await fetchGroceryListByID(listID: listID)
        return fetchedList
    }

    private func fetchGroceryListByID(listID: UUID) async -> GroceryList? {
        do {
            let fetchedList = try await groceryListService.fetchGroceryList(
                byID: listID
            )
            groceryLists[listID] = fetchedList
            return fetchedList
        } catch {
            print(
                "Failed to fetch specific grocery list: \(error.localizedDescription)"
            )
    }
        return nil
    }

    func toggleListActiveState(for listId: UUID) {
        if groceryLists[listId] != nil {
            groceryLists[listId]?.isActive.toggle()
        }
    }

}
