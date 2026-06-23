//
//  ProductModel.swift
//  Grocer
//
//  Created by Emil on 6/17/26.
//

import Foundation
import SwiftUI

struct Product: Decodable, Identifiable {
    let id: String
    let productName: String
    let price: Double
    let measurementDescription: String
    let measurement: Double
    let supermarketName: String
    let imageURL: String
}
