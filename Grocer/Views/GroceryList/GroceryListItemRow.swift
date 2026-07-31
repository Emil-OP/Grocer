//
//  GroceryListItemRow.swift
//  Grocer
//
//  Created by Emil on 7/31/26.
//
import SwiftUI

struct GroceryListItemRow: View {

        let product: GroceryListItem

        var body: some View {
            HStack {
                HStack(spacing: 10) {
                    rowLogo(for: product.item.supermarketName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40)
                        .cornerRadius(10)

                    VStack(alignment: .leading) {
                        Text(product.item.productName)
                            .lineLimit(1)
                            .padding(.leading, 0)
                        Text(
                            "\(product.item.measurement.roundedString()) \(product.item.measurementDescription)"
                        )
                        .font(.caption)
                        .foregroundStyle(.gray.opacity(0.8))
                    }

                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(
                            "\(product.item.price.roundedString())"
                        )
                        .fontWeight(.bold)
                        HStack {
                            Text("Cant. ")
                                .foregroundStyle(.gray.opacity(0.8))
                            Text("\(product.quantity)")
                        }
                    }
                }
                .padding(10)
                .glassEffect(
                    .regular.interactive(),
                    in: RoundedRectangle(cornerRadius: 20)
                )
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
    }
