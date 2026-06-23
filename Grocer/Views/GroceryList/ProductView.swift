//
//  ProductView.swift
//  Grocer
//
//  Created by Emil on 6/23/26.
//

import SwiftUI

struct ProductView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var cantidad: Int = 1
    @State private var selectedAge = 18
    let product: Product

    var body: some View {
        VStack(spacing: 20) {
            AsyncImageView(imageURL: product.imageURL)

            Text(product.productName)
                .font(.title)
                .bold()
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Cantidad")
                        .font(.title3)
                        .bold()
                    Text(
                        product.measurement.roundedString() + " "
                            + product.measurementDescription
                    )

                }
                Spacer()
                VStack(alignment: .trailing, spacing: 10) {
                    Text("Precio")
                        .font(.title3)
                        .bold()
                    Text("$\(product.price.roundedString())")
                }
            }
            Spacer()
            Stepper("Cantidad: \(cantidad)", value: $cantidad, in: 1...1000)

            Button {
                print("Added \(cantidad)")
                dismiss()

                //TODO:
                //Still need to add a grocery list for the user in order to add this item somewhere
            } label: {
                Text("Agregar")
                    .font(.title)
                    .bold()
                    .shadow(color: .black, radius: 0.2)

                    .frame(maxWidth: .infinity)

            }
            .buttonStyle(.glassProminent)

        }
        .padding()
    }
}

struct AsyncImageView: View {
    
    let imageURL: String
    var body: some View {
        AsyncImage(url: URL(string: imageURL)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .failure:
                Image(systemName: "photo")
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(20)
                    .frame(maxWidth: .infinity)
            @unknown default:
                EmptyView()
            }
        }
    }
}

#Preview {
    ProductView(
        product: .init(
            id: "1",
            productName: "Queso Cottage Breakstone 4% Grasa 16oz",
            price: 329.35,
            measurementDescription: "oz",
            measurement: 16,
            supermarketName: "El Nacional",
            imageURL:
                "https://supermercadosnacional.com/media/catalog/product/B/R/BREAKSTONE_COTTAGE_CHEESE_SC_4_16_OZ.jpg?optimize=medium&bg-color=255,255,255&fit=bounds&height=300&width=240&canvas=240:300"
        )
    )
}
