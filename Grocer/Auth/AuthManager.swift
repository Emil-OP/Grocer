//
//  AuthManager.swift
//  Grocer
//
//  Created by Emil on 7/20/26.
//

import Foundation

@Observable
final class AuthManager {
    var token: String = "" {
        didSet {
            if token.isEmpty {
                KeychainHelper.shared.delete(for: "access_token")
            } else {
                KeychainHelper.shared.save(token, for: "access_token")
            }
        }
    }
    
    var isAuthenticated: Bool {
        !token.isEmpty
    }
    
    init(){
        let existingToken = KeychainHelper.shared.readString(for: "access_token")
        self.token = existingToken ?? ""
    }
    
    func login(with newToken: String){
        token = newToken
    }
    
    func logout(){
        token = ""
    }
}
