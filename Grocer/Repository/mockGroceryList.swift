//
//  mockGroceryList.swift
//  Grocer
//
//  Created by Emil on 6/24/26.
//


import SwiftUI

let mockGroceryLists: [GroceryList] = [
        
    // 1. A standard list (Weekend BBQ)
    GroceryList(
        id: UUID.init(uuidString: "1")!,
        name: "Weekend BBQ 🥩",
        items: [
            GroceryListItem(
                product: Product(id: UUID.init(uuidString: "101")!, productName: "Salami Induveca", price: 150.0, measurementDescription: "lb", measurement: 1.0, supermarketName: "El Nacional", imageURL: ""),
                quantity: 2,
                parentLists: [UUID.init(uuidString: "1")! : 2]
            ),
            GroceryListItem(
                product: Product(id: UUID.init(uuidString: "102")!, productName: "Refresco Rojo", price: 65.0, measurementDescription: "liters", measurement: 2.0, supermarketName: "Jumbo", imageURL: ""),
                quantity: 3,
                parentLists: [UUID.init(uuidString: "1")! : 3]
            ),
            GroceryListItem(
                product: Product(id: UUID.init(uuidString: "106")!, productName: "Carne de Cerdo", price: 220.0, measurementDescription: "lb", measurement: 1.0, supermarketName: "El Nacional", imageURL: ""),
                quantity: 4,
                parentLists: [UUID.init(uuidString: "1")! : 4]
            ),
            GroceryListItem(
                product: Product(id: UUID.init(uuidString: "107")!, productName: "Queso de Freír Geo", price: 310.0, measurementDescription: "lb", measurement: 1.0, supermarketName: "El Nacional", imageURL: ""),
                quantity: 2,
                parentLists: [UUID.init(uuidString: "1")! : 2]
            ),
            GroceryListItem(
                product: Product(id: UUID.init(uuidString: "108")!, productName: "Cerveza Presidente", price: 120.0, measurementDescription: "botella", measurement: 1.0, supermarketName: "Jumbo", imageURL: ""),
                quantity: 12,
                parentLists: [UUID.init(uuidString: "1")! : 12]
            ),
            GroceryListItem(
                product: Product(id: UUID.init(uuidString: "109")!, productName: "Carbón", price: 150.0, measurementDescription: "funda", measurement: 1.0, supermarketName: "La Sirena", imageURL: ""),
                quantity: 1,
                parentLists: [UUID.init(uuidString: "1")! : 1]
            )
        ],
        purchasedItems: []
    ),
    
    // 2. A list with a mix of pending and purchased products
    GroceryList(
        id: UUID.init(uuidString: "2")!,
        name: "Weekly Essentials 🛒",
        items: [
            GroceryListItem(
                product: Product(id: UUID.init(uuidString: "103")!, productName: "Arroz Campo", price: 350.0, measurementDescription: "lbs", measurement: 10.0, supermarketName: "PriceSmart", imageURL: ""),
                quantity: 1,
                parentLists: [UUID.init(uuidString: "2")! : 1]
            ),
            GroceryListItem(
                product: Product(id: UUID.init(uuidString: "110")!, productName: "Habichuelas Rojas", price: 85.0, measurementDescription: "lata", measurement: 1.0, supermarketName: "PriceSmart", imageURL: ""),
                quantity: 4,
                parentLists: [UUID.init(uuidString: "2")! : 4]
            ),
            GroceryListItem(
                product: Product(id: UUID.init(uuidString: "111")!, productName: "Aceite Crisol", price: 450.0, measurementDescription: "galón", measurement: 1.0, supermarketName: "La Sirena", imageURL: ""),
                quantity: 1,
                parentLists: [UUID.init(uuidString: "2")! : 1]
            ),
            GroceryListItem(
                product: Product(id: UUID.init(uuidString: "112")!, productName: "Leche Listamilk", price: 75.0, measurementDescription: "litro", measurement: 1.0, supermarketName: "La Sirena", imageURL: ""),
                quantity: 6,
                parentLists: [UUID.init(uuidString: "2")! : 6]
            ),
            GroceryListItem(
                product: Product(id: UUID.init(uuidString: "113")!, productName: "Pan de Agua", price: 50.0, measurementDescription: "funda", measurement: 1.0, supermarketName: "La Sirena", imageURL: ""),
                quantity: 2,
                parentLists: [UUID.init(uuidString: "2")! : 2]
            )
        ],
        purchasedItems: [
            GroceryListItem(
                product: Product(id: UUID.init(uuidString: "104")!, productName: "Plátano Verde", price: 25.0, measurementDescription: "unidad", measurement: 1.0, supermarketName: "La Sirena", imageURL: ""),
                quantity: 12,
                parentLists: [UUID.init(uuidString: "2")! : 12]
            ),
            GroceryListItem(
                product: Product(id: UUID.init(uuidString: "105")!, productName: "Huevos", price: 180.0, measurementDescription: "cartón", measurement: 1.0, supermarketName: "La Sirena", imageURL: ""),
                quantity: 1,
                parentLists: [UUID.init(uuidString: "2")! : 1]
            ),
            GroceryListItem(
                product: Product(id: UUID.init(uuidString: "114")!, productName: "Café Santo Domingo", price: 210.0, measurementDescription: "paquete", measurement: 1.0, supermarketName: "La Sirena", imageURL: ""),
                quantity: 2,
                parentLists: [UUID.init(uuidString: "2")! : 2]
            ),
            GroceryListItem(
                product: Product(id: UUID.init(uuidString: "115")!, productName: "Azúcar Crema", price: 45.0, measurementDescription: "lb", measurement: 1.0, supermarketName: "La Sirena", imageURL: ""),
                quantity: 3,
                parentLists: [UUID.init(uuidString: "2")! : 3]
            )
        ]
    ),
    
    // 3. A list heavily focused on party items, overlapping some IDs for testing!
    GroceryList(
        id: UUID(),
        name: "Party Supplies 🎉",
        items: [
            GroceryListItem(
                // Overlapping ID 101 to test your Master List combining logic!
                product: Product(id: UUID.init(uuidString: "101")!, productName: "Salami Induveca", price: 150.0, measurementDescription: "lb", measurement: 1.0, supermarketName: "El Nacional", imageURL: ""),
                quantity: 1,
                parentLists: [UUID.init(uuidString: "2")! : 1]
            ),
            GroceryListItem(
                product: Product(id: UUID.init(uuidString: "116")!, productName: "Ron Brugal Añejo", price: 850.0, measurementDescription: "botella", measurement: 1.0, supermarketName: "Jumbo", imageURL: ""),
                quantity: 2,
                parentLists: [UUID.init(uuidString: "2")! : 2]
            ),
            GroceryListItem(
                product: Product(id: UUID.init(uuidString: "117")!, productName: "Hielo", price: 60.0, measurementDescription: "funda", measurement: 1.0, supermarketName: "Jumbo", imageURL: ""),
                quantity: 3,
                parentLists: [UUID.init(uuidString: "2")! : 3]
            ),
            GroceryListItem(
                product: Product(id: UUID.init(uuidString: "118")!, productName: "Vasos Plásticos", price: 120.0, measurementDescription: "paquete", measurement: 1.0, supermarketName: "Jumbo", imageURL: ""),
                quantity: 2,
                parentLists: [UUID.init(uuidString: "2")! : 2]
            ),
            GroceryListItem(
                product: Product(id: UUID.init(uuidString: "119")!, productName: "Coca-Cola", price: 80.0, measurementDescription: "litros", measurement: 2.0, supermarketName: "Jumbo", imageURL: ""),
                quantity: 4,
                parentLists: [UUID.init(uuidString: "2")! : 4]
            )
        ],
        purchasedItems: []
    )
]


