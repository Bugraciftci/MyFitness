//
//  ContentView.swift
//  MyFitness
//
//  Created by Muhammed Buğra on 2.01.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MuscleListView(muscles: muscles)
                .tabItem {
                    Label("Muscles", systemImage: "dumbbell.fill")
                }
            
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "star.fill")
                }
            
            PersonalWorkoutView()
                .tabItem {
                    Label("Workout Plan", systemImage: "list.bullet")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(FavoritesManager()) 
    }
}
