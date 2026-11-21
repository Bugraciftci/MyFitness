//
//  MyFitnessApp.swift
//  MyFitness
//

import SwiftUI

@main
struct MyFitnessApp: App {
    @StateObject private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            MainTabView(
                discoverVM: container.discoverViewModel,
                workoutVM: container.workoutViewModel,
                profileVM: container.profileViewModel
            )
            .environmentObject(container)
            .preferredColorScheme(container.profileViewModel.preferredColorScheme)
        }
    }
}
