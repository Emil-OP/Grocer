//
//  GrocerApp.swift
//  Grocer
//
//  Created by Emil on 6/2/26.
//

import SwiftUI

@main
struct GrocerApp: App {
    @State private var authManager: AuthManager
    @State private var apiClient: APIClient
    
    init() {
        let manager = AuthManager()
        _authManager = State(initialValue: manager)
        _apiClient = State(initialValue: APIClient(baseURL: .apiBaseURL, tokenProvider: manager))
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .environment(apiClient)
        }
    }
}
