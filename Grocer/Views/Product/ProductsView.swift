//
//  ListView.swift
//  Grocer
//
//  Created by Emil on 6/17/26.
//

import SwiftUI

struct ProductsView: View {

    @Environment(ProductRepository.self) private var productRepo
    @State private var searchString: String = ""
    @State private var selectedItem: Product?
    @State private var isSearchActive = true
    var filteredProducts: [Product] {
        if searchString.isEmpty {
            return productRepo.products
        } else {
            return productRepo.products.filter {
                $0.productName.lowercased().contains(searchString.lowercased())
            }
        }
    }
    var body: some View {
        NavigationStack {

            List(filteredProducts) { product in
                ProductListItem(product: product)
                    .onAppear {
                        if product.id == productRepo.products.last?.id {
                            Task {
                                await productRepo.loadNextProductPage()
                            }
                        }
                    }
                    .onTapGesture {
                        selectedItem = product
                    }
            }
            .scrollIndicators(.hidden)
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .listRowSpacing(-23)
            .searchable(text: $searchString)
            .onChange(of: searchString) { oldValue, newValue in
                Task {
                    if !newValue.isEmpty {
                        await productRepo.searchForProduct(
                            productName: newValue
                        )
                    }
                }
            }
            .task {
                if productRepo.products.isEmpty {
                    await productRepo.loadNextProductPage()
                }
            }
            .sheet(item: $selectedItem) { item in
                ProductView(product: item)
            }
        }
    }
}


struct ProductListItem: View {

    let product: Product

    var body: some View {
        HStack(spacing: 10) {
            rowLogo(for: product.supermarketName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40)
                .cornerRadius(10)

            VStack(alignment: .leading) {
                Text(product.productName)
                    .lineLimit(1)
                    .padding(.leading, 0)
                Text(
                    "\(product.measurement.roundedString()) \(product.measurementDescription)"
                )
                .font(.caption)
                .foregroundStyle(.gray.opacity(0.8))
            }

            Spacer()
            Text("DOP")
                .font(.subheadline)
                .foregroundStyle(.gray.opacity(0.8))
            Text(
                "\(product.price.roundedString())"
            )
            .fontWeight(.bold)
        }
        .padding(10)
        .glassEffect(
            .regular.interactive(),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}

#Preview {
    NavigationStack {
        ProductsView()
    }
    .environment(ProductRepository())
}
