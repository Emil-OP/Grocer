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
        name: "Weekend BBQ 🥩",
        items: [
            GroceryListItem(
                product: Product(id: "101", productName: "Salami Induveca", price: 150.0, measurementDescription: "lb", measurement: 1.0, supermarketName: "El Nacional", imageURL: ""),
                quantity: 2
            ),
            GroceryListItem(
                product: Product(id: "102", productName: "Refresco Rojo", price: 65.0, measurementDescription: "liters", measurement: 2.0, supermarketName: "Jumbo", imageURL: ""),
                quantity: 3
            ),
            GroceryListItem(
                product: Product(id: "106", productName: "Carne de Cerdo", price: 220.0, measurementDescription: "lb", measurement: 1.0, supermarketName: "El Nacional", imageURL: ""),
                quantity: 4
            ),
            GroceryListItem(
                product: Product(id: "107", productName: "Queso de Freír Geo", price: 310.0, measurementDescription: "lb", measurement: 1.0, supermarketName: "El Nacional", imageURL: ""),
                quantity: 2
            ),
            GroceryListItem(
                product: Product(id: "108", productName: "Cerveza Presidente", price: 120.0, measurementDescription: "botella", measurement: 1.0, supermarketName: "Jumbo", imageURL: ""),
                quantity: 12
            ),
            GroceryListItem(
                product: Product(id: "109", productName: "Carbón", price: 150.0, measurementDescription: "funda", measurement: 1.0, supermarketName: "La Sirena", imageURL: ""),
                quantity: 1
            )
        ],
        purchasedItems: []
    ),
    
    // 2. A list with a mix of pending and purchased products
    GroceryList(
        name: "Weekly Essentials 🛒",
        items: [
            GroceryListItem(
                product: Product(id: "103", productName: "Arroz Campo", price: 350.0, measurementDescription: "lbs", measurement: 10.0, supermarketName: "PriceSmart", imageURL: ""),
                quantity: 1
            ),
            GroceryListItem(
                product: Product(id: "110", productName: "Habichuelas Rojas", price: 85.0, measurementDescription: "lata", measurement: 1.0, supermarketName: "PriceSmart", imageURL: ""),
                quantity: 4
            ),
            GroceryListItem(
                product: Product(id: "111", productName: "Aceite Crisol", price: 450.0, measurementDescription: "galón", measurement: 1.0, supermarketName: "La Sirena", imageURL: ""),
                quantity: 1
            ),
            GroceryListItem(
                product: Product(id: "112", productName: "Leche Listamilk", price: 75.0, measurementDescription: "litro", measurement: 1.0, supermarketName: "La Sirena", imageURL: ""),
                quantity: 6
            ),
            GroceryListItem(
                product: Product(id: "113", productName: "Pan de Agua", price: 50.0, measurementDescription: "funda", measurement: 1.0, supermarketName: "La Sirena", imageURL: ""),
                quantity: 2
            )
        ],
        purchasedItems: [
            GroceryListItem(
                product: Product(id: "104", productName: "Plátano Verde", price: 25.0, measurementDescription: "unidad", measurement: 1.0, supermarketName: "La Sirena", imageURL: ""),
                quantity: 12
            ),
            GroceryListItem(
                product: Product(id: "105", productName: "Huevos", price: 180.0, measurementDescription: "cartón", measurement: 1.0, supermarketName: "La Sirena", imageURL: ""),
                quantity: 1
            ),
            GroceryListItem(
                product: Product(id: "114", productName: "Café Santo Domingo", price: 210.0, measurementDescription: "paquete", measurement: 1.0, supermarketName: "La Sirena", imageURL: ""),
                quantity: 2
            ),
            GroceryListItem(
                product: Product(id: "115", productName: "Azúcar Crema", price: 45.0, measurementDescription: "lb", measurement: 1.0, supermarketName: "La Sirena", imageURL: ""),
                quantity: 3
            )
        ]
    ),
    
    // 3. A list heavily focused on party items, overlapping some IDs for testing!
    GroceryList(
        name: "Party Supplies 🎉",
        items: [
            GroceryListItem(
                // Overlapping ID 101 to test your Master List combining logic!
                product: Product(id: "101", productName: "Salami Induveca", price: 150.0, measurementDescription: "lb", measurement: 1.0, supermarketName: "El Nacional", imageURL: ""),
                quantity: 1
            ),
            GroceryListItem(
                product: Product(id: "116", productName: "Ron Brugal Añejo", price: 850.0, measurementDescription: "botella", measurement: 1.0, supermarketName: "Jumbo", imageURL: ""),
                quantity: 2
            ),
            GroceryListItem(
                product: Product(id: "117", productName: "Hielo", price: 60.0, measurementDescription: "funda", measurement: 1.0, supermarketName: "Jumbo", imageURL: ""),
                quantity: 3
            ),
            GroceryListItem(
                product: Product(id: "118", productName: "Vasos Plásticos", price: 120.0, measurementDescription: "paquete", measurement: 1.0, supermarketName: "Jumbo", imageURL: ""),
                quantity: 2
            ),
            GroceryListItem(
                product: Product(id: "119", productName: "Coca-Cola", price: 80.0, measurementDescription: "litros", measurement: 2.0, supermarketName: "Jumbo", imageURL: ""),
                quantity: 4
            )
        ],
        purchasedItems: []
    )
]
