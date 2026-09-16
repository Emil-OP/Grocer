//
//  ProductService.swift
//  Grocer
//
//  Created by Emil on 6/22/26.
//

import Foundation

protocol ProductServiceProtocol {
    func fetchProducts(page : Int,limit: Int) async throws -> [UUID:Product]
    func fetchProductByName(productName : String) async throws -> [UUID:Product]
}

class ProductService : ProductServiceProtocol {
    
    let accessToken = KeychainHelper.shared.readString(for: "access_token") ?? ""
    
    let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String
    
    func fetchProducts(page : Int,limit : Int = 20) async throws -> [UUID:Product]{
        
        guard let baseURL else {
            throw URLError(.badURL)
        }
        
        guard let url = URL(string: "\(baseURL)/products?page=\(page)&limit=\(limit)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        request.setValue("application/json",forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200
        else { throw URLError(.badServerResponse)}
        
        let decodedProducts = try JSONDecoder().decode([Product].self, from: data)
        
        return decodedProducts.reduce(into:[UUID:Product]()){dict, product in
            dict[product.id] = product}
    }
    
    func fetchProductByName(productName : String) async throws -> [UUID:Product] {
        guard let baseURL else {
            throw URLError(.badURL)
        }
        guard let url = URL(string: "\(baseURL)/search?q=\(productName)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        request.setValue("application/json",forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200
        else { throw URLError(.badServerResponse)}
        
        let decodedProducts = try JSONDecoder().decode([Product].self, from: data)
        
        return decodedProducts.reduce(into: [UUID:Product]()) { dict, product in
            dict[product.id] = product
        }
    }
}
