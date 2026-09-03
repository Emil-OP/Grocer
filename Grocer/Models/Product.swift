//
//  ProductModel.swift
//  Grocer
//
//  Created by Emil on 6/17/26.
//

import Foundation
import SwiftUI

struct Product: Decodable, Identifiable, Equatable {
    let id: UUID
    let productName: String
    let price: Double
    let measurementDescription: String
    let measurement: Double
    let supermarketName: String
    let imageURL: String

    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey{
        case id
        case productName = "product_name"
        case price
        case measurementDescription = "measurement_description"
        case measurement
        case supermarketName = "supermarket_name"
        case imageURL = "image_url"
    }

}
