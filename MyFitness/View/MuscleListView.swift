//
//  HomeView.swift
//  MyFitness
//
//  Created by Muhammed Buğra on 2.01.2024.
//

import SwiftUI

struct MuscleListView: View {
    var muscles: [Muscle]
    
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            // LazyVGrid ile ızgara yapısını oluşturun
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(muscles, id: \.name) { muscle in
                        NavigationLink(destination: MuscleDetailView(muscle: muscle)) {
                            ZStack {
                                muscle.photo
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150)
                                    .cornerRadius(12)
                                Text(muscle.name)
                                    .font(.title2)
                                    .foregroundColor(.cyan)
                            }
                            .padding(.all, 10)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.all, 10)
            }
            .navigationBarItems(leading:
                                    Text("Metin 1")
                .font(.headline) // Yazı tipi ve boyutunu ayarlayın
                .foregroundColor(.blue) // Metin rengini ayarlayın
                .padding(.trailing, 20) // Metinden sonra boşluk ekleyin
                                , trailing:
                                    Text("Metin 2")
                .font(.headline) // Yazı tipi ve boyutunu ayarlayın
                .foregroundColor(.green) // Metin rengini ayarlayın
                .padding(.leading, 20)) // Metinden önce boşluk ekleyin
        }
    }
}


// Preview
struct MuscleListView_Previews: PreviewProvider {
    static var previews: some View {
        MuscleListView(muscles: muscles)
    }
}
