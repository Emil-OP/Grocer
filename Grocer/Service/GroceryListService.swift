//
//  GroceryListService.swift
//  Grocer
//
//  Created by Emil on 7/24/26.
//

//TODO: create/insert/toggle should be modified to return a response code/id. Sending the whole list is inefficient.

import Foundation

protocol GroceryListServiceProtocol {
    func fetchGroceryLists() async throws -> [GroceryList]
    func createGroceryList(groceryListName: String) async throws -> GroceryList
    func insertGroceryListItem(item: GroceryListItem, into listId: UUID)
        async throws -> GroceryList
    func toggleItemStatus(
        for glItemID: UUID,
        inListWithID listId: UUID,
        isPurchased: Bool
    ) async throws -> GroceryList
    func fetchGroceryList(byID listId: UUID) async throws -> GroceryList
}

struct GroceryListService: GroceryListServiceProtocol {
    
    let apiClient: any APIClientProtocol

    init(apiClient: any APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchGroceryLists() async throws -> [GroceryList] {
        try await apiClient.send(
            Endpoint(
                path: "/grocery-lists",
                method: .get,
                body: nil
            )
        )

    }

    func createGroceryList(groceryListName: String) async throws -> GroceryList {
        try await apiClient.send(
            Endpoint(
                path: "/grocery-lists",
                method: .post,
                body: ["name": groceryListName]
            )
        )
    }

    func insertGroceryListItem(item: GroceryListItem, into listId: UUID) async throws -> GroceryList {
        struct InsertPayload: Encodable {
            let productId: String
            let amount: Int
        }

        let payload = InsertPayload(
            productId: item.item.id.uuidString,
            amount: item.amount
        )
        
        
        return try await apiClient.send(
            Endpoint(
                path: "/grocery-lists/\(listId.uuidString)/items",
                method: .post,
                body: payload
            )
        )
    }

    func toggleItemStatus(for glItemID: UUID,inListWithID listId: UUID,isPurchased: Bool) async throws -> GroceryList {
        return try await apiClient.send(
            Endpoint(
                path: "/grocery-lists/\(listId.uuidString)/items/\(glItemID.uuidString)",
                method: .patch,
                body: ["isPurchased" : isPurchased]
            )
        )
    }

    func fetchGroceryList(byID listId: UUID) async throws -> GroceryList {
        return try await apiClient.send(
            Endpoint(
                path: "/grocery-lists/\(listId.uuidString)",
                method: .get,
                body: nil
            )
        )
    }
}
