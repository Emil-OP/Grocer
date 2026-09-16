//
//  ProductRepository.swift
//  Grocer
//
//  Created by Emil on 6/22/26.
//

import Foundation

@Observable
class ProductRepository {
    private(set) var products: [UUID: Product] = [:]
    private(set) var isLoading: Bool = false
    private(set) var error: Error?
    private(set) var hasReachedEnd = false
    private(set) var currentPage = 1
    private(set) var sortedProducts: [Product] = []

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

                var tempDictionary = newProducts.reduce(into: [UUID: Product]())
                {
                    dict,
                    product in
                    dict[product.id] = product
                }

                self.products = self.products.merging(tempDictionary) {
                    (_, new) in new
                }

                self.sortedProducts = self.products.values.sorted {
                    $0.productName < $1.productName
                }
                currentPage += 1
            }
        } catch {
            print("Failed to load products: \(error.localizedDescription)")
        }
    }

    func searchForProduct(productName: String) async {
        guard !isLoading else { return }
        error = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let newProducts = try await productService.fetchProductByName(
                productName: productName
            )

            var tempDictionary = newProducts.reduce(into: [UUID: Product]()) {
                dict,
                product in
                dict[product.id] = product
            }

            self.products = self.products.merging(tempDictionary) { (_, new) in
                new
            }
            self.sortedProducts = self.products.values.sorted {
                $0.productName < $1.productName
            }
        } catch {
            print("Failed to search products: \(error.localizedDescription)")
        }
    }

}
