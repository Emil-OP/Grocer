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
    @State private var groceryListRepo = GroceryListRepository()
    @State private var selectedTab: TabItems = .myLists

    var body: some View {

        VStack {
            if !authManager.isAuthenticated {
                LoginView()
                    .onAppear {
                        selectedTab = .myLists
                    }
            } else {
                MainTabView(selectedTab: $selectedTab)
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
