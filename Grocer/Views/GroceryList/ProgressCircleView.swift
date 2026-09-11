//
//  ProgressCircleView.swift
//  Grocer
//
//  Created by Emil on 7/29/26.
//

import SwiftUI

struct ProgressCircleView: View {
    
    var completedPercentage: Double
    
    var body: some View {
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
}

#Preview {
    ProgressCircleView(completedPercentage: 83.0)
}
