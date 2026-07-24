//
//  AuthManager.swift
//  Grocer
//
//  Created by Emil on 7/20/26.
//

import Foundation

@Observable
final class AuthManager {
    var accessToken: String = "" {
        didSet {
            if accessToken.isEmpty {
                KeychainHelper.shared.delete(for: "access_token")
            } else {
                KeychainHelper.shared.save(accessToken, for: "access_token")
            }
        }
    }
    
    var refreshToken: String = "" {
            didSet {
                if refreshToken.isEmpty {
                    KeychainHelper.shared.delete(for: "refresh_token")
                } else {
                    KeychainHelper.shared.save(refreshToken, for: "refresh_token")
                }
            }
        }
    
    var isAuthenticated: Bool {
        !accessToken.isEmpty
    }
    
    init(){
        let existingAccessToken = KeychainHelper.shared.readString(for: "access_token")
        self.accessToken = existingAccessToken ?? ""
        
        let existingRefreshToken = KeychainHelper.shared.readString(for: "refresh_token")
        self.refreshToken = existingRefreshToken ?? ""
    }
    
    func login(with accessToken: String, and refreshToken: String){
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    func logout(){
        accessToken = ""
        refreshToken = ""
    }
}
