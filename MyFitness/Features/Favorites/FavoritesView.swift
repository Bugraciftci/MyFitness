//
//  FavoritesView.swift
//  MyFitness
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var discoverVM: DiscoverViewModel
    @ObservedObject var workoutVM: WorkoutViewModel
    @ObservedObject var profileVM: ProfileViewModel

    var body: some View {
        NavigationStack {
            Group {
                if discoverVM.favoriteExercises.isEmpty {
                    ContentUnavailableView(
                        "No Saved Exercises",
                        systemImage: "bookmark.slash",
                        description: Text("Bookmark exercises in Discover to build your personal quick-access library.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(discoverVM.favoriteExercises) { exercise in
                                NavigationLink(value: exercise) {
                                    ExerciseRowCard(
                                        exercise: exercise,
                                        isFavorite: true,
                                        onToggleFavorite: {
                                            withAnimation(.snappy) {
                                                discoverVM.toggleFavorite(exercise)
                                            }
                                            HapticEngine.impact(.light, enabled: profileVM.preferences.hapticsEnabled)
                                        }
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.sm)
                    }
                }
            }
            .background(AppTheme.surfaceGrouped)
            .navigationTitle("Saved")
            .navigationDestination(for: Exercise.self) { exercise in
                ExerciseDetailView(
                    exercise: exercise,
                    discoverVM: discoverVM,
                    workoutVM: workoutVM,
                    profileVM: profileVM
                )
            }
        }
    }
}
