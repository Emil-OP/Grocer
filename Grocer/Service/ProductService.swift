//
//  ProductService.swift
//  Grocer
//
//  Created by Emil on 6/22/26.
//

import Foundation

protocol ProductServiceProtocol {
    func fetchProducts(page: Int, limit: Int) async throws -> [Product]
    func fetchProductByName(productName: String) async throws -> [Product]
}

class ProductService: ProductServiceProtocol {

    let apiClient: any APIClientProtocol
    
    init(apiClient: any APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchProducts(page: Int, limit: Int = 20) async throws -> [Product] {
        
        let queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        return try await apiClient.send(Endpoint(path: "/products",queryItems: queryItems, method: .get, body: nil))

    }

    func fetchProductByName(productName: String) async throws -> [Product] {
        
        let queryItems = [
            URLQueryItem(name: "q", value: productName)
        ]
        
        return try await apiClient.send(Endpoint(path: "/search",queryItems: queryItems, method: .get, body: nil))

    }
}
