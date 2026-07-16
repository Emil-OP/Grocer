//
//  GroceryListsView.swift
//  Grocer
//
//  Created by Emil on 6/24/26.
//

import SwiftUI

struct GroceryListsView: View {

    @State var groceryLists: [GroceryList]

    @State var masterList: [GroceryListItem] = []

    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach($groceryLists) { list in
                        GroceryListCardView(groceryList: list)

                    }
                }
                .padding()
            }
            .scrollIndicators(.hidden)

            List(masterList) { item in
                GroceryListItemRow(product: item)
            }.scrollIndicators(.hidden)
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .listRowSpacing(-23)
        }
        .onAppear {
            buildMasterLists()
        }
        .onChange(of: groceryLists) { oldValue, newValue in
            withAnimation {
                buildMasterLists()
            }
        }
    }
    func buildMasterLists() {
        var tempMasterList: [GroceryListItem] = []

        for groceryList in groceryLists {
            if groceryList.isActive {
                for item in groceryList.items {
                    tempMasterList.append(item)
                }
            }
        }

        var tempList: [GroceryListItem] = []

        for item in tempMasterList {
            let duplicates = tempMasterList.filter { $0.id == item.id }
            if duplicates.count > 1 {
                tempMasterList = tempMasterList.filter { $0.id != item.id }
                let itemCount = duplicates.reduce(0) { $0 + $1.quantity }
                var tempItem = item
                tempItem.quantity = itemCount
                tempList.append(tempItem)
            }
            if (tempList.filter { $0.id == item.id }.count == 0) {
                tempList.append(item)
            }
        }

        masterList = tempList.sorted{$0.item.supermarketName < $1.item.supermarketName}
    }
}

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


#Preview {
    GroceryListsView(groceryLists: mockGroceryLists)
}
