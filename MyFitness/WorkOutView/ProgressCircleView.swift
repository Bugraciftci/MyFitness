//
//  ProgressCircleView.swift
//  MyFitness
//
//  Created by Muhammed Buğra on 6.01.2024.
//

import SwiftUI

struct ProgressCircleView: View {
    var percentage: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 5.0)
                .opacity(0.3)
                .foregroundColor(.blue)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.percentage, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 5.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
            
            Text(String(format: "%.0f %%", min(self.percentage, 1.0)*100.0))
                .font(.caption)
                .bold()
        }
        .frame(width: 50, height: 50)
    }
}


#Preview {
    ProgressCircleView(percentage: 56.0)
}
