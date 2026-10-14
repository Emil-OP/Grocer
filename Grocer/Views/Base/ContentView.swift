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
    @Environment(APIClient.self) private var apiClient
    @State private var selectedTab: TabItems = .myLists

    var body: some View {
            if !authManager.isAuthenticated {
                LoginView()
                    .onAppear {
                        selectedTab = .myLists
                    }
                    .ignoresSafeArea()
            } else {
                MainTabView(apiClient: apiClient,selectedTab: $selectedTab)
                    .ignoresSafeArea()
            }
    }

}

#Preview {
    
    @Previewable var manager = AuthManager()
    ContentView()
        .environment(manager)
        .environment(APIClient(baseURL: .apiBaseURL, tokenProvider: manager))
}
