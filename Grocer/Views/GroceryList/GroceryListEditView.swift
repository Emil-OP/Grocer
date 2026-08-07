//
//  GroceryListEditView.swift
//  Grocer
//
//  Created by Emil on 7/29/26.
//

import SwiftUI

struct GroceryListEditView: View {
    @Environment(GroceryListRepository.self) private var groceryListRepo
    let currentListId: UUID

    var groceryList: GroceryList {
        for list in groceryListRepo.groceryLists {
            if list.id == currentListId {
                return list
            }
        }
        return mockGroceryLists[1]
    }

    var supermarketNames: Set<String> {
        Set(groceryList.items.map { $0.item.supermarketName })
    }

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(groceryList.name)
                        .font(.title)
                        .bold()
                    HStack {
                        ForEach(supermarketNames.sorted(), id: \.self) { name in
                            rowLogo(for: name)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40)
                                .cornerRadius(10)
                        }
                    }
                }
                Spacer()
                ProgressCircleView(
                    numerator: groceryList.purchasedItems.count,
                    denominator: groceryList.items.count
                )
            }
            .padding([.top, .leading, .trailing])
            ScrollView {
                ForEach(groceryList.items) { item in
                    GroceryListItemRow(product: item)
                        .listRowInsets(EdgeInsets())
                }.scrollIndicators(.hidden)
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .listRowSpacing(7)
                ForEach(groceryList.purchasedItems) { item in
                    GroceryListItemRow(product: item)
                        .listRowInsets(EdgeInsets())
                        .grayscale(1)
                        .overlay(Color.black.opacity(0.8))
                }.scrollIndicators(.hidden)
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .listRowSpacing(7)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Circle()
                .foregroundStyle(.blue)
                .frame(width: 50)
                .background(
                    Image(systemName: "plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20,height:20)
                        .foregroundStyle(.primary)
                )
                .glassEffect(.regular.interactive())
                .padding()
        }
    }
}

#Preview {
    let mockRepo = GroceryListRepository()

    return GroceryListEditView(
        currentListId: UUID(uuidString: "0528017b-8810-4098-ad30-037cca4a8b86")!
    )
    .ignoresSafeArea(edges: .bottom)
    .environment(mockRepo)
    .task {
        await mockRepo.loadGroceryLists()
    }
}
