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
    
    func fetchProducts(page : Int,limit : Int = 20) async throws -> [Product]{
        let endpoint  = "http://localhost:3300/products?page=\(page)&limit=\(limit)"
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200
        else { throw URLError(.badServerResponse)}
        
        return try JSONDecoder().decode([Product].self, from: data)
//        do {
//                    return try JSONDecoder().decode([Product].self, from: data)
//                } catch let DecodingError.keyNotFound(key, _) {
//                    print("❌ SWIFT ERROR: Missing key in JSON: \(key.stringValue)")
//                    throw URLError(.cannotParseResponse)
//                } catch let DecodingError.typeMismatch(type, context) {
//                    print("❌ SWIFT ERROR: Type mismatch! Expected \(type) at path: \(context.codingPath.map(\.stringValue).joined(separator: "."))")
//                    throw URLError(.cannotParseResponse)
//                } catch let DecodingError.valueNotFound(type, context) {
//                    print("❌ SWIFT ERROR: Expected \(type) but found null at path: \(context.codingPath.map(\.stringValue).joined(separator: "."))")
//                    throw URLError(.cannotParseResponse)
//                }
    }
    
    func fetchProductByName(productName : String) async throws -> [Product] {
        let endpoint = "http://localhost:3300/search?q=\(productName)"
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200
        else { throw URLError(.badServerResponse)}
        
        return try JSONDecoder().decode([Product].self, from: data)
    }
}
