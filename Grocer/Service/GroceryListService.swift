//
//  GroceryListService.swift
//  Grocer
//
//  Created by Emil on 7/24/26.
//

import Foundation

protocol GroceryListServiceProtocol {
    func fetchGroceryLists() async throws -> [GroceryList]
    func createGroceryList(groceryListName: String) async throws -> GroceryList
    func insertGroceryListItem(item: GroceryListItem, into listId: UUID) async throws -> GroceryList
    func toggleItemStatus(for productId: UUID, inListWithID listId: UUID, isPurchased: Bool) async throws -> GroceryList
    func fetchGroceryList(byID listId: UUID) async throws -> GroceryList
}

struct GroceryListService: GroceryListServiceProtocol {
    
    var accessToken: String{
        AuthManager.shared.accessToken
    }
    
    let baseURL =
        Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String

    func fetchGroceryLists() async throws -> [GroceryList] {
        
        guard let baseURL else {
            throw URLError(.badURL)
        }
        
        guard let url = URL(string: "\(baseURL)/grocery-lists") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(
            "Bearer \(accessToken)",
            forHTTPHeaderField: "authorization"
        )
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
           guard response.statusCode == 200
        else {
                    if let serverErrorMessage = String(data: data, encoding: .utf8) {
                        print("Server Message: \(serverErrorMessage)")
                    }
            throw URLError(.badServerResponse) }
        
        do {
            
            let decoder = JSONDecoder()
            let groceryLists = try decoder.decode(
                [GroceryList].self,
                from: data
            )
            
            return groceryLists
        } catch {
            print("Decoding error in fetchGroceryLists: \(error)")
            throw error
        }
    }

    func createGroceryList(groceryListName: String) async throws -> GroceryList {
        guard let baseURL else {
            throw URLError(.badURL)
        }

        guard let url = URL(string: "\(baseURL)/grocery-lists") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(
            "Bearer \(accessToken)",
            forHTTPHeaderField: "authorization"
        )

        let body = ["name": groceryListName]

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200...299).contains(response.statusCode) else {
            print("Failed to create grocery list: \(response.statusCode)")
            throw URLError(.badServerResponse)
        }
        do {
            let createdList = try JSONDecoder().decode(
                GroceryList.self,
                from: data
            )
            return createdList
        } catch {
            print("Decoding error in createGroceryList: \(error)")
            throw error
        }

    }

    func insertGroceryListItem(item: GroceryListItem, into listId: UUID) async throws -> GroceryList {
        guard let baseURL else {
            throw URLError(.badURL)
        }

        guard
            let url = URL(
                string: "\(baseURL)/grocery-lists/\(listId.uuidString)/items"
            )
        else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(
            "Bearer \(accessToken)",
            forHTTPHeaderField: "authorization"
        )

        struct InsertPayload: Encodable {
            let productId: String
            let quantity: Int
        }

        let payload = InsertPayload(productId: item.id.uuidString, quantity: item.quantity)

        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse,
            response.statusCode == 200
        else { throw URLError(.badServerResponse) }
        do {
            let updatedList = try JSONDecoder().decode(
                GroceryList.self,
                from: data
            )
            return updatedList
        } catch {
            print("Decoding Error in insertGroceryListItem: \(error)")
            throw error
        }
    }
    
    func toggleItemStatus(for productId: UUID, inListWithID listId: UUID, isPurchased: Bool) async throws -> GroceryList{
        guard let baseURL else {
            throw URLError(.badURL)
        }

        guard
            let url = URL(
                string: "\(baseURL)/grocery-lists/\(listId.uuidString)/items/\(productId.uuidString)"
            )
        else {
            throw URLError(.badURL)
        }
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(
            "Bearer \(accessToken)",
            forHTTPHeaderField: "authorization"
        )
        let body = ["isPurchased" : isPurchased]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse,
            response.statusCode == 200
        else { throw URLError(.badServerResponse) }
        
        do {
            let updatedList = try JSONDecoder().decode(
                GroceryList.self,
                from: data
            )
            return updatedList
        } catch {
            print("Decoding Error in toggleItemStatus: \(error)")
            throw error
        }
        
    }
    
    func fetchGroceryList(byID listId: UUID) async throws -> GroceryList {
        guard let baseURL else {
            throw URLError(.badURL)
        }

        guard let url = URL(string: "\(baseURL)/grocery-lists/\(listId.uuidString)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        do {
            
            let list = try JSONDecoder().decode(GroceryList.self, from: data)
            return list
        } catch {
            print("Decoding Error in fetchGroceryList(byID:): \(error)")
            throw error
        }
    }
}


