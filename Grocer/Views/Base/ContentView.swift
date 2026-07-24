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
    @Environment(AuthManager.self) private var authManager
    @State private var productRepo = ProductRepository()
    @State private var selectedTab: TabItems = .myLists
    

    var body: some View {
        
        VStack{
            if !authManager.isAuthenticated{
                LoginView()
                    .onAppear {
                        selectedTab = .myLists
                    }
            } else {
                TabView(selection: $selectedTab) {
                    Tab("Home", systemImage: "house", value: .home) {
                        Text("Under construction")
                    }
                    Tab("Lists",systemImage: "checklist.unchecked",value: .myLists) {
                        GroceryListsView(groceryLists: mockGroceryLists)
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
                .tabBarMinimizeBehavior(.onScrollDown)
            }
        }
        .padding()
        .ignoresSafeArea()
        
        
    }
        
}

#Preview {
    ContentView()
        .environment(AuthManager())
}


