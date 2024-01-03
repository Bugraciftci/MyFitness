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
                    Label("Home", systemImage: "house.fill")
                }
            
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "star.fill")
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
            .environmentObject(FavoritesManager())  // FavoritesManager örneğini sağla
    }
}
