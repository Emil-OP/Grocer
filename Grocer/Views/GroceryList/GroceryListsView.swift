//
//  GroceryListsView.swift
//  Grocer
//
//  Created by Emil on 6/24/26.
//

import SwiftUI

struct GroceryListsView: View {
    @Environment(GroceryListRepository.self) private var groceryRepo

    var masterList: [GroceryListItem] {
        var tempMasterList: [GroceryListItem] = []
        for groceryList in groceryRepo.groceryLists {
            if groceryList.isActive {
                for item in groceryList.items {
                    tempMasterList.append(item)
                }
            }
        }
        return tempMasterList.sorted{$0.item.supermarketName < $1.item.supermarketName}
    }
    var purchasedMasterList: [GroceryListItem] {
        var tempPurchasedMasterList: [GroceryListItem] = []

        for groceryList in groceryRepo.groceryLists {
            if groceryList.isActive {
                for item in groceryList.purchasedItems {
                    tempPurchasedMasterList.append(item)
                }
            }
        }
        return tempPurchasedMasterList.sorted{$0.item.supermarketName < $1.item.supermarketName}
    }
    @State var isActive: Bool = false
    @State var isForm: Bool = false
    @State var listName: String = ""
    @State var isValid = true
    @State var isEditingMode = false
    @State var currentListId: UUID = UUID()

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.horizontal) {
                    HStack {
                        VStack {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(.gray)
                        }
                        .padding()
                        .frame(maxWidth: 80)
                        .frame(height: 140)
                        .glassEffect(
                            .clear.interactive(),
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                        .opacity(0.5)
                        .onTapGesture {
                            isForm.toggle()
                        }
                        .sheet(isPresented: $isForm) {

                            VStack(alignment: .leading, spacing: 20) {
                                Spacer()
                                Text("Agregar lista nueva:")
                                    .font(.title2)
                                    .bold()
                                Text("Nombre:")
                                    .bold()
                                TextField(text: $listName) {
                                    Text("Ej: Parrillada de Playa")
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(
                                                    isValid ? .clear : .red,
                                                    lineWidth: 3
                                                )
                                        )
                                )

                                Text("Campo requerido")
                                    .foregroundStyle(.red)
                                    .font(.caption)
                                    .opacity(isValid ? 0 : 1)

                                Button {
                                    Task {
                                        if !listName.isEmpty {
                                            await groceryRepo.createGroceryList(
                                                groceryListName: listName
                                            )
                                            listName = ""
                                            isValid = true
                                            if groceryRepo.groceryLists.first
                                                != nil
                                            {
                                                currentListId =
                                                    groceryRepo.groceryLists[0]
                                                    .id
                                            }
                                            isEditingMode = true
                                            isForm.toggle()
                                        } else {
                                            withAnimation {
                                                isValid.toggle()
                                            }
                                        }
                                    }
                                } label: {
                                    Text("Agregar lista nueva")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.glassProminent)

                            }
                            .padding()
                            .presentationDetents([.height(250)])

                        }

                        if groceryRepo.groceryLists.isEmpty {
                            Text(
                                "Aún no has creado una lista de compras!\nPulsa aqui para empezar!"
                            )
                        } else {
                            ForEach(groceryRepo.groceryLists) { list in
                                GroceryListCardView(groceryList: list)
                                    .onTapGesture {
                                        withAnimation {
                                            groceryRepo.toggleListActiveState(
                                                for: list.id
                                            )
                                        }
                                    }
                                    .onLongPressGesture {
                                        currentListId = list.id
                                        isEditingMode = true
                                    }
                                    
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 150)
                }
                .scrollIndicators(.hidden)

                if groceryRepo.groceryLists.isEmpty {
                    Spacer()
                    Image(systemName: "checklist")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100)
                        .foregroundStyle(.gray.opacity(0.2))
                    Spacer()
                } else {
                    ScrollView {
                        ForEach(masterList) { item in
                            GroceryListItemRow(product: item)
                                .listRowInsets(EdgeInsets())
                                .onTapGesture {
                                    Task{
                                        for list in item.parentLists {
                                            await groceryRepo.toggleItemAsPurchased(for: item.item.id, inList: list.key, isPurchased: false)
                                        }
                                    }
                                }
                        }.scrollIndicators(.hidden)
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .listRowSpacing(7)
                        ForEach(purchasedMasterList) { item in
                            GroceryListItemRow(product: item)
                                .listRowInsets(EdgeInsets())
                                .grayscale(1)
                                .overlay(Color.black.opacity(0.8))
                                .onTapGesture {
                                    Task{
                                        for list in item.parentLists {
                                            await groceryRepo.toggleItemAsPurchased(for: item.item.id, inList: list.key, isPurchased: true)
                                        }
                                    }
                                }
                        }.scrollIndicators(.hidden)
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .listRowSpacing(7)
                    }
                }

            }
            .navigationDestination(isPresented: $isEditingMode) {
                GroceryListEditView(currentListId: currentListId)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .task {
            if groceryRepo.groceryLists.isEmpty {
                await groceryRepo.loadGroceryLists()
            }
        }
    }
    func unDupeList(dupedList: [GroceryListItem]) -> [GroceryListItem] {
        var mergedItems: [String: GroceryListItem] = [:]

        for item in dupedList {
            if var existingItem = mergedItems[item.id.uuidString] {
                existingItem.quantity += item.quantity
                mergedItems[item.id.uuidString] = existingItem
            } else {
                mergedItems[item.id.uuidString] = item
            }
        }
        return mergedItems.values.sorted {
            $0.item.supermarketName < $1.item.supermarketName
        }
    }
}

#Preview {
    GroceryListsView()
        .environment(GroceryListRepository())
}
