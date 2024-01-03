//
//  MuscleDetailView.swift
//  MyFitness
//
//  Created by Muhammed Buğra on 2.01.2024.
//

import SwiftUI

struct MuscleDetailView: View {
    var muscle: Muscle
    
    var body: some View {
        ScrollView {
            VStack {
                muscle.photo
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding()
                Text(muscle.name)
                    .font(.largeTitle)
                    .padding()
            }
        }
        .navigationTitle("\(muscle.name) exercise")
    }
}

#Preview {
    MuscleDetailView(muscle: muscles[0])
}
