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
    @State private var selectedItem : Product?
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
            .sheet(item: $selectedItem){ item in
                    ProductView(product: item)
            }

        }

    }

    //    func rowColor(for supermarketName: String) -> [Color] {
    //        switch supermarketName {
    //        case "Jumbo":
    //            [Color.jumboPrimary, .white]
    //        case "El Nacional":
    //            [Color.nacionalPrimary, .white]
    //        case "La Sirena":
    //            [Color.sirenaPrimary, Color.sirenaSecondary]
    //        case "PriceSmart":
    //            [Color.priceSmartPrimary, Color.priceSmartSecondary]
    //        default:
    //            [Color.white]
    //        }
    //    }
    func rowLogo(for supermarketName: String) -> Image {
        switch supermarketName {
        case "Jumbo":
            Image("jumboLogo")
        case "El Nacional":
            Image("nacionalLogo")
        case "La Sirena":
            Image("sirenaLogo")
        case "PriceSmart":
            Image("priceSmartLogo")
        default:
            Image(systemName: "questionmark.circle.fill")
        }
    }
}

#Preview {
    NavigationStack {
        ProductsView()
    }
    .environment(ProductRepository())
}
