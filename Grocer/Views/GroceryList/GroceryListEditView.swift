//
//  GroceryListEditView.swift
//  Grocer
//
//  Created by Emil on 7/29/26.
//

import SwiftUI

struct GroceryListEditView: View {
    
    let currentListId: UUID
    var groceryList: GroceryList {
        for list in mockGroceryLists {
            if list.id == currentListId {
                return list
            }
        }
        return GroceryList(id: UUID(),name: "List not found, fix this error Emil", items: [], purchasedItems: [])
    }
    
    var body: some View {
        Text(groceryList.name)
    }
}

#Preview {
    GroceryListEditView(currentListId: UUID(uuidString: "7BA6B52C-1297-4B4A-BFAC-7B7BB8268712")!)
}
