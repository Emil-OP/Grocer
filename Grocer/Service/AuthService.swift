//
//  AuthService.swift
//  Grocer
//
//  Created by Emil on 7/20/26.
//

import Foundation

protocol AuthServiceProtocol {
    func login(username: String, password: String) async throws -> LoginResponse
    func register(username: String, password: String, name: String) async throws -> RegistrationResponse
    func refresh(refreshToken: String) async throws -> RefreshResponse
}

class AuthService: AuthServiceProtocol {

    let baseURL =
        Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String

    func login(username: String, password: String) async throws -> LoginResponse {
        let loginPayload = LoginPayload(username: username, password: password)

        guard let baseURL else {
            throw URLError(.badURL)
        }
        guard let url = URL(string: "\(baseURL)/login") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = try JSONEncoder().encode(loginPayload)
        request.httpBody = payload

        let (data, _) = try await URLSession.shared.data(for: request)
        let loginResponse = try JSONDecoder().decode(
            LoginResponse.self,
            from: data
        )
        return loginResponse
    }

    func register(username: String, password: String, name: String) async throws -> RegistrationResponse {
        let registrationPayload = RegistrationPayload(
            username: username,
            password: password,
            name: name
        )

        guard let baseURL else {
            throw URLError(.badURL)
        }
        guard let url = URL(string: "\(baseURL)/register") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(registrationPayload)

        let (data, _) = try await URLSession.shared.data(for: request)
        let registrationResponse = try JSONDecoder().decode(
            RegistrationResponse.self,
            from: data
        )
        return registrationResponse
    }
    func refresh(refreshToken: String) async throws -> RefreshResponse {
        let refreshPayload = RefreshPayload(refreshToken: refreshToken)
        guard let baseURL else {
            throw URLError(.badURL)
        }
        guard let url = URL(string: "\(baseURL)/refresh") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(refreshPayload)
        
        let (data, _ ) = try await URLSession.shared.data(for: request)
        let refreshResponse = try JSONDecoder().decode(RefreshResponse.self,from: data)
        
        return refreshResponse
    }
}

// DTOs

//MARK: Login

struct LoginPayload: Encodable {
    let username: String
    let password: String
}

struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

//MARK: Registration

struct RegistrationPayload: Encodable {
    let username: String
    let password: String
    let name: String
}

struct RegistrationResponse: Decodable {
    let accessToken: String
    let username: String
    let name: String

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case username
        case name
    }
}

//MARK: REFRESH

struct RefreshPayload: Encodable{
    let refreshToken: String
}
struct RefreshResponse: Decodable {
    let accessToken: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

