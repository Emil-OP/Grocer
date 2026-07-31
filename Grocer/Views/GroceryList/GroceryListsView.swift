//
//  GroceryListsView.swift
//  Grocer
//
//  Created by Emil on 6/24/26.
//

import SwiftUI

struct GroceryListsView: View {
    @Environment(GroceryListRepository.self) private var groceryRepo

    @State var masterList: [GroceryListItem] = []
    @State var purchasedMasterList: [GroceryListItem] = []

    @State var isForm: Bool = false
    @State var listName: String = ""
    @State var isValid = true
    @State var isNewListSubmitted = false
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
                                            if let newestList = groceryRepo
                                                .groceryLists.first
                                            {
                                                currentListId =
                                                    groceryRepo.groceryLists[0]
                                                    .id
                                            }
                                            isNewListSubmitted = true
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
                        }.scrollIndicators(.hidden)
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .listRowSpacing(7)
                        ForEach(purchasedMasterList) { item in
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

            }
            .onAppear {
                buildMasterLists()
            }
            .onChange(of: groceryRepo.groceryLists) { oldValue, newValue in
                withAnimation {
                    buildMasterLists()
                }
            }
            .navigationDestination(isPresented: $isNewListSubmitted) {
                GroceryListEditView(currentListId: currentListId)

            }
        }
        .task {
            if groceryRepo.groceryLists.isEmpty {
                await groceryRepo.loadGroceryLists()
            }
        }
    }

    func buildMasterLists() {
        var tempMasterList: [GroceryListItem] = []

        for groceryList in groceryRepo.groceryLists {
            if groceryList.isActive {
                for item in groceryList.items {
                    tempMasterList.append(item)
                }
            }
        }
        masterList = unDupeList(dupedList: tempMasterList)

        tempMasterList = []

        for groceryList in groceryRepo.groceryLists {
            if groceryList.isActive {
                for item in groceryList.purchasedItems {
                    tempMasterList.append(item)
                }
            }
        }
        purchasedMasterList = unDupeList(dupedList: tempMasterList)

    }

    //    func unDupeList(dupedList: [GroceryListItem]) -> [GroceryListItem]{
    //        var tempList: [GroceryListItem] = []
    //        var list = dupedList
    //
    //        for item in list {
    //            let duplicates = list.filter { $0.id == item.id }
    //            if duplicates.count > 1 {
    //                list = list.filter { $0.id != item.id }
    //                let itemCount = duplicates.reduce(0) { $0 + $1.quantity }
    //                var tempItem = item
    //                tempItem.quantity = itemCount
    //                tempList.append(tempItem)
    //            }
    //            if tempList.filter({ $0.id == item.id }).count == 0 {
    //                tempList.append(item)
    //            }
    //        }
    //
    //        return tempList.sorted {
    //            $0.item.supermarketName < $1.item.supermarketName
    //        }
    //    }
    //}
    func unDupeList(dupedList: [GroceryListItem]) -> [GroceryListItem] {
        // 1. Create a dictionary to hold unique items by their ID
        var mergedItems: [String: GroceryListItem] = [:]  // Use your item's ID type if not UUID

        // 2. Loop exactly once (O(N) time complexity)
        for item in dupedList {
            if var existingItem = mergedItems[item.id] {
                // If it exists, just add the quantity
                existingItem.quantity += item.quantity
                mergedItems[item.id] = existingItem
            } else {
                // If it's new, add it to the dictionary
                mergedItems[item.id] = item
            }
        }

        // 3. Convert back to an array and sort
        return mergedItems.values.sorted {
            $0.item.supermarketName < $1.item.supermarketName
        }
    }
}

#Preview {
    GroceryListsView()
        .environment(GroceryListRepository())
}
