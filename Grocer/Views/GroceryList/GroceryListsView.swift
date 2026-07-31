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
                                    if !listName.isEmpty {
                                        groceryLists.insert(
                                            GroceryList(
                                                id: UUID(),
                                                name: listName,
                                                items: [],
                                                purchasedItems: []
                                            ),
                                            at: 0
                                        )
                                        listName = ""
                                        isValid = true
                                        currentListId = groceryLists[0].id
                                        isNewListSubmitted = true
                                        isForm.toggle()
                                    } else {
                                        withAnimation {
                                            isValid.toggle()
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

                        ForEach($groceryLists) { list in
                            GroceryListCardView(groceryList: list)

                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 150)
                }
                .scrollIndicators(.hidden)

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
            .onAppear {
                buildMasterLists()
            }
            .onChange(of: groceryLists) { oldValue, newValue in
                withAnimation {
                    buildMasterLists()
                }
            }
            .navigationDestination(isPresented: $isNewListSubmitted) {
                GroceryListEditView(currentListId: currentListId)
                
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
        masterList = unDupeList(dupedList: tempMasterList)
        
        tempMasterList = []
        
        for groceryList in groceryLists {
            if groceryList.isActive {
                for item in groceryList.purchasedItems {
                    tempMasterList.append(item)
                }
            }
        }
        purchasedMasterList = unDupeList(dupedList: tempMasterList)
        
        
    }
    
    func unDupeList(dupedList: [GroceryListItem]) -> [GroceryListItem]{
        var tempList: [GroceryListItem] = []
        var list = dupedList

        for item in list {
            let duplicates = list.filter { $0.id == item.id }
            if duplicates.count > 1 {
                list = list.filter { $0.id != item.id }
                let itemCount = duplicates.reduce(0) { $0 + $1.quantity }
                var tempItem = item
                tempItem.quantity = itemCount
                tempList.append(tempItem)
            }
            if tempList.filter({ $0.id == item.id }).count == 0 {
                tempList.append(item)
            }
        }

        return tempList.sorted {
            $0.item.supermarketName < $1.item.supermarketName
        }
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
