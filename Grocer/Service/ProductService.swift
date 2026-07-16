//
//  ProductService.swift
//  Grocer
//
//  Created by Emil on 6/22/26.
//

import Foundation

protocol ProductServiceProtocol {
    func fetchProducts(page : Int,limit: Int) async throws -> [Product]
    func fetchProductByName(productName : String) async throws -> [Product]
}

class ProductService : ProductServiceProtocol {
    
    let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String
    
    func fetchProducts(page : Int,limit : Int = 20) async throws -> [Product]{
        
        guard let baseURL else {
            throw URLError(.badURL)
        }
        let endpoint = "\(baseURL)/products?page=\(page)&limit=\(limit)"
        
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200
        else { throw URLError(.badServerResponse)}
        
        return try JSONDecoder().decode([Product].self, from: data)
    }
    
    func fetchProductByName(productName : String) async throws -> [Product] {
        guard let baseURL else {
            throw URLError(.badURL)
        }
        let endpoint  = "\(baseURL)/search?q=\(productName)"
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200
        else { throw URLError(.badServerResponse)}
        
        return try JSONDecoder().decode([Product].self, from: data)
    }
}
