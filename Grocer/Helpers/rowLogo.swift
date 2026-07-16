//
//  rowLogo.swift
//  Grocer
//
//  Created by Emil on 6/26/26.
//

import SwiftUI

func rowLogo(for supermarketName: String) -> Image {
    switch supermarketName {
    case "Jumbo":
        Image("jumboLogo")
    case "El Nacional":
        Image("nacionalLogo")
    case "La Sirena":
        Image("sirenaLogo")
    case "PriceSmart":
        Image("priceSmartLogo")
    default:
        Image(systemName: "questionmark.circle.fill")
    }
}
