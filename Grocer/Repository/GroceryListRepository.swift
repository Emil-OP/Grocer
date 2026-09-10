//
//  GroceryListRepository.swift
//  Grocer
//
//  Created by Emil on 7/31/26.
//

import Foundation

@Observable
class GroceryListRepository{
    
    private(set) var groceryLists: [GroceryList] = []
    private(set) var isLoading: Bool = false
    private let groceryListService: any GroceryListServiceProtocol
    
    init(groceryListService: any GroceryListServiceProtocol = GroceryListService()) {
        self.groceryListService = groceryListService
    }
    
    func loadGroceryLists() async {
        guard !isLoading else {return}
        isLoading = true
        defer { isLoading = false}
        
        do {
            print("Loading grocery list onto local repo.")
            groceryLists = try await groceryListService.fetchGroceryLists()
            print("Loaded grocery list onto local repo successffully")
        } catch {
            print("Failed to load grocery lists onto local repository: \(error.localizedDescription)")
        }
    }
    
    func createGroceryList(groceryListName: String) async {
        do {
            let newList = try await groceryListService.createGroceryList(groceryListName: groceryListName)
            groceryLists.insert(newList, at: 0)
        } catch {
            print("Failed to add new grocery list onto local repository: \(error.localizedDescription)")
        }
    }
    
    func addItemToGroceryList(item: GroceryListItem, into listWithID: UUID) async {
        do {
            let updatedList = try await groceryListService.insertGroceryListItem(item: item, into: listWithID)
            groceryLists = groceryLists.map{$0.id == updatedList.id ? updatedList : $0 }
        } catch {
            print("Failed to insert item into grocery list: \(error.localizedDescription)")
        }
    }
    
    func toggleItemAsPurchased(for glItemID: UUID, inList listID: UUID, isPurchased: Bool) async {
        do{
            let updatedList = try await groceryListService.toggleItemStatus(for: glItemID, inListWithID: listID, isPurchased: isPurchased)
            var tempList: [GroceryList] = []
            tempList.append(contentsOf: groceryLists.map{$0.id == updatedList.id ? updatedList : $0 })
            groceryLists = []
            groceryLists.append(contentsOf: tempList)
            
        }catch{
            print("Failed to toggle item: \(error.localizedDescription)")
        }
    }
    
    
    func fetchGroceryListByID(listID: UUID) async {
        do {
            let fetchedList = try await groceryListService.fetchGroceryList(byID: listID)
            if let index = groceryLists.firstIndex(where: { $0.id == listID }) {
                groceryLists[index] = fetchedList
            } else {
                groceryLists.append(fetchedList)
            }
        } catch {
            print("Failed to fetch specific grocery list: \(error.localizedDescription)")
        }
    }
    
    func toggleListActiveState(for listId: UUID) {
        if let index = groceryLists.firstIndex(where: { $0.id == listId }) {
            groceryLists[index].isActive.toggle()
        }
    }
    
}
