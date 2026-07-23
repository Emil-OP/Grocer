//
//  GroceryListCardView.swift
//  Grocer
//
//  Created by Emil on 6/25/26.
//

import SwiftUI

struct GroceryListCardView: View {
    
    @Binding var groceryList : GroceryList
    private var completedPercentage : Double {
        guard !groceryList.items.isEmpty else {return 0}
        return (Double(groceryList.purchasedItems.count)/(Double(groceryList.items.count) + Double(groceryList.purchasedItems.count)))*100
    }
    
   
    
    
    var body: some View {
        VStack {
           
            VStack(alignment: .leading) {
                Text(groceryList.name)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .padding(.leading, 0)
                Text(
                    "\(groceryList.items.count) items"
                )
                .font(.caption)
                .foregroundStyle(.gray.opacity(0.8))
            }
            ZStack{
                Circle()
                    .stroke(.gray.opacity(0.2),lineWidth: 10)
                    .frame(width: 80, height:80)
                Text("%\(completedPercentage.roundedString(precision: 0))")
                Circle()
                    .trim(from: 0.0, to: CGFloat(completedPercentage)/100)
                    .stroke(.green,lineWidth: 10)
                    .frame(width: 80, height:80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration:1.0),value:CGFloat(completedPercentage/100))
            }
        }
        .padding()
        .frame(maxWidth: 175)
        .glassEffect(
            .regular.interactive(),
            in: RoundedRectangle(cornerRadius: 20)
        )

        .scaleEffect(groceryList.isActive ? 1 : 0.95)
        .grayscale(groceryList.isActive ? 0 : 1)
        .onTapGesture {
            withAnimation(){
                groceryList.isActive.toggle()
            }
        }
    }
}

#Preview {
    
    @Previewable @State var gList = mockGroceryLists
    
    GroceryListCardView(groceryList: $gList[0])
}
