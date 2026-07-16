//
//  GroceryListAlternativeView.swift
//  Grocer
//
//  Created by Emil on 6/25/26.
//

import SwiftUI

struct GroceryListAlternativeView: View {

    let groceryList: GroceryList
    let circleDim: CGFloat = 50
    var circleStroke: CGFloat{
        circleDim/8
    }
    private var completedPercentage: Double {
        guard !groceryList.items.isEmpty else { return 0 }
        return
            (Double(groceryList.purchasedItems.count)
            / (Double(groceryList.items.count)
                + Double(groceryList.purchasedItems.count)))
            * 100
    }

    var body: some View {
        HStack {

            VStack(alignment: .leading) {
                Text(groceryList.name)
                    .lineLimit(1)
                    .padding(.leading, 0)
                Text(
                    "\(groceryList.items.count) items"
                )
                .font(.caption)
                .foregroundStyle(.gray.opacity(0.8))
            }

            Spacer()
            ZStack {
                Circle()
                    .stroke(.gray.opacity(0.2), lineWidth: circleStroke)
                    .frame(width: circleDim, height: circleDim)
                Text("%\(completedPercentage.roundedString(precision: 0))")
                Circle()
                    .trim(from: 0.0, to: CGFloat(completedPercentage) / 100)
                    .stroke(.green, lineWidth: circleStroke)
                    .frame(width: circleDim, height: circleDim)
                    .rotationEffect(.degrees(-90))
                    .animation(
                        .easeInOut(duration: 1.0),
                        value: CGFloat(completedPercentage / 100)
                    )
            }
        }
        .padding(10)
        .glassEffect(
            .regular.interactive(),
            in: RoundedRectangle(cornerRadius: 20)
        )
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}

#Preview {
    GroceryListAlternativeView(groceryList: mockGroceryLists[0])
}
