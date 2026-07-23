//
//  GrocerApp.swift
//  Grocer
//
//  Created by Emil on 6/2/26.
//

import SwiftUI

@main
struct GrocerApp: App {
    @State private var authManager = AuthManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
        }
    }
}
