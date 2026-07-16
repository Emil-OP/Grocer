//
//  ContentView.swift
//  Grocer
//
//  Created by Emil on 6/2/26.
//

import SwiftUI

enum TabItems {
    case home
    case myLists
    case settings
    case search
}

struct ContentView: View {
    @State private var productRepo = ProductRepository()
    @State private var selectedTab: TabItems = .myLists

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: .home) {
                Text("Under construction")
            }
            Tab("Lists",systemImage: "checklist.unchecked",value: .myLists) {
                GroceryListsView(groceryLists: mockGroceryLists)
            }
            Tab("Settings", systemImage: "gearshape.fill", value: .settings) {
                Text("Under construction")
            }
            Tab(value: .search, role: .search) {
                ProductsView()
            }

        }
        .environment(productRepo)
        .tabBarMinimizeBehavior(.onScrollDown)
        
    }
}

#Preview {
    ContentView()
}


