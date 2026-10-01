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

    @State private var groceryList: GroceryList?
    
    var supermarketNames: Set<String> {
        if let list = groceryList {
            return Set(list.items.map { $0.item.supermarketName })
        } else {
            return []
        }
    }

    var body: some View {
        if let list = groceryList {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(list.name)
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
                        completedPercentage: list.completedPercentage
                    )
                }
                .padding([.top, .leading, .trailing])
                ScrollView {
                    ForEach(list.items) { item in
                        GroceryListItemRow(product: item)
                            .listRowInsets(EdgeInsets())
                    }.scrollIndicators(.hidden)
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .listRowSpacing(7)
                    ForEach(list.purchasedItems) { item in
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
            .task{
                groceryList = await groceryListRepo.getGroceryListById(listID: currentListId)
            }
        }
    }
}

#Preview {
    let mockRepo = GroceryListRepository()

    GroceryListEditView(
        currentListId: UUID(uuidString: "0528017b-8810-4098-ad30-037cca4a8b86")!
    )
    .ignoresSafeArea(edges: .bottom)
    .environment(mockRepo)
    .task {
        await mockRepo.loadGroceryLists()
    }
}
