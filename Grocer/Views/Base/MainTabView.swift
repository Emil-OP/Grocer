//
//  MainTabView.swift
//  Grocer
//
//  Created by Emil on 7/31/26.
//

import SwiftUI

struct MainTabView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var productRepo = ProductRepository()
    @State private var groceryListRepo = GroceryListRepository()
    @Binding var selectedTab: TabItems
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: .home) {
                Text("Under construction")
            }
            Tab("Lists",systemImage: "checklist.unchecked",value: .myLists) {
                GroceryListsView()
            }
            Tab("Settings", systemImage: "gearshape.fill", value: .settings) {
                Button{
                    authManager.logout()
                } label: {
                    Text("Cerrar sesión")
                }
            }
            Tab(value: .search, role: .search) {
                ProductsView()
            }
        }
        .environment(productRepo)
        .environment(groceryListRepo)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    @Previewable @State var tab = TabItems.myLists
    MainTabView(selectedTab: $tab)
        .environment(AuthManager())
}
