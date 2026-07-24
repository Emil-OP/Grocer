//
//  AuthController.swift
//  Grocer
//
//  Created by Emil on 7/24/26.
//

//MARK: Remember you commented out 3 things. @observable in AuthManager file @state and envornment modifier in GrocerApp file

import Foundation

struct AuthController {
    private let authService: any AuthServiceProtocol
    let authManager: AuthManager
    
    init(authService: any AuthServiceProtocol, authManager: AuthManager) {
            self.authService = authService
            self.authManager = authManager
        }
    
    func login(username: String, password: String) async throws{
        let loginResponse = try await authService.login(username: username, password: password)
        authManager.login(with: loginResponse.accessToken)
    }
    
    func register(username: String, password: String, name: String) async throws {
        let registerResponse = try await authService.register(username: username, password: password, name: name)
        authManager.login(with: registerResponse.accessToken)
    }
}
