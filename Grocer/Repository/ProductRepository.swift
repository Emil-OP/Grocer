//
//  ProductRepository.swift
//  Grocer
//
//  Created by Emil on 6/22/26.
//

import Foundation

@Observable
class ProductRepository {
    private(set) var products: [Product] = []
    private(set) var isLoading: Bool = false
    private(set) var error: Error?
    private(set) var hasReachedEnd = false
    private(set) var currentPage = 1

    private let productService: any ProductServiceProtocol

    init(productService: any ProductServiceProtocol = ProductService()) {
        self.productService = productService
    }

    func loadNextProductPage() async {
        guard !isLoading && !hasReachedEnd else { return }
        error = nil
        isLoading = true

        defer { isLoading = false }

        do {
            let newProducts = try await productService.fetchProducts(
                page: currentPage,
                limit: 20
            )

            if newProducts.isEmpty {
                hasReachedEnd = true
            } else {
                products.append(contentsOf: newProducts)
                currentPage += 1
            }
        } catch {
            print("Failed to load products: \(error.localizedDescription)")
        }
    }
    
    func searchForProduct(productName : String) async {
        guard !isLoading else { return }
        error = nil
        isLoading = true
        defer { isLoading = false }
        
        do {
            let newProducts = try await productService.fetchProductByName(productName: productName)
            
            products.append(contentsOf: newProducts)
        } catch {
            print("Failed to search products: \(error.localizedDescription)")
        }
    }

}
