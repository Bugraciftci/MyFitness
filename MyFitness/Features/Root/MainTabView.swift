//
//  MainTabView.swift
//  MyFitness
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var container: AppContainer
    @ObservedObject var discoverVM: DiscoverViewModel
    @ObservedObject var workoutVM: WorkoutViewModel
    @ObservedObject var profileVM: ProfileViewModel

    @State private var selectedTab: Tab = .discover

    enum Tab: Hashable {
        case discover
        case workouts
        case saved
        case profile
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DiscoverView(
                viewModel: discoverVM,
                workoutVM: workoutVM,
                profileVM: profileVM
            )
            .tabItem {
                Label("Discover", systemImage: "figure.strengthtraining.traditional")
            }
            .tag(Tab.discover)

            WorkoutsView(
                workoutVM: workoutVM,
                discoverVM: discoverVM,
                profileVM: profileVM
            )
            .tabItem {
                Label("Workouts", systemImage: "flame.fill")
            }
            .tag(Tab.workouts)

            FavoritesView(
                discoverVM: discoverVM,
                workoutVM: workoutVM,
                profileVM: profileVM
            )
            .tabItem {
                Label("Saved", systemImage: "bookmark.fill")
            }
            .badge(discoverVM.favoriteIDs.count)
            .tag(Tab.saved)

            ProfileView(
                profileVM: profileVM,
                workoutVM: workoutVM,
                discoverVM: discoverVM
            )
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle.fill")
            }
            .tag(Tab.profile)
        }
        .tint(AppTheme.brandAccent)
        .sheet(isPresented: $workoutVM.isSessionActive) {
            ActiveSessionView(
                workoutVM: workoutVM,
                discoverVM: discoverVM,
                profileVM: profileVM
            )
            .interactiveDismissDisabled(workoutVM.activeCompletedSetsCount > 0)
        }
        .task {
            await discoverVM.loadLiveCatalogIfNeeded()
        }
    }
}
