//
//  APIClient.swift
//  Grocer
//
//  Created by Emil on 10/9/26.
//

import Foundation

protocol APIClientProtocol {
    func send<T:Decodable>(_ endpoint: Endpoint) async throws -> T
    func send(_ endpoint: Endpoint) async throws
}

struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]?
    let method: HTTPMethod
    let body: Encodable?
    let requireAuth: Bool
    
    init(path: String, queryItems: [URLQueryItem]? = nil, method: HTTPMethod, body: Encodable?, requireAuth: Bool = true) {
        self.path = path
        self.queryItems = queryItems
        self.method = method
        self.body = body
        self.requireAuth = requireAuth
    }
}

enum HTTPMethod: String{
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case put = "PUT"
    case delete = "DELETE"
    
}
@Observable
final class APIClient: APIClientProtocol{
    
    private let baseURL: URL
    private let tokenProvider: TokenProviding
    private let session: URLSession
    
    init(baseURL: URL, tokenProvider: TokenProviding, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.tokenProvider = tokenProvider
        self.session = session
    }
    func send<T>(_ endpoint: Endpoint) async throws -> T where T : Decodable {
        let request = try buildRequest(for: endpoint)
        let (data, response) = try await session.data(for: request)
        try validate(response)
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw ServiceError.decodingError(error)
        }
    }
    
    func send(_ endpoint: Endpoint) async throws {
        let request = try buildRequest(for: endpoint)
        let (_, response) = try await session.data(for: request)
        try validate(response)
    }
    
    private func buildRequest(for endpoint: Endpoint) throws -> URLRequest{
        var components = URLComponents(
            url: self.baseURL.appending(path: endpoint.path),
            resolvingAgainstBaseURL: false
        )
        
        if endpoint.queryItems != [] {
            components?.queryItems = endpoint.queryItems
        }

        guard let url = components?.url else {
            throw ServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if endpoint.requireAuth {
            request.setValue( "Bearer \(tokenProvider.accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        return request
    }
    
    private func validate(_ response: URLResponse) throws {
        guard let response = response as? HTTPURLResponse else {
            throw ServiceError.badResponse
        }
        
        guard (200...299).contains(response.statusCode) else {
            throw ServiceError.serverError(statusCode: response.statusCode)
        }
    }
}

