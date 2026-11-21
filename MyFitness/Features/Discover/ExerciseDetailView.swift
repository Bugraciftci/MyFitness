//
//  ExerciseDetailView.swift
//  MyFitness
//

import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    @ObservedObject var discoverVM: DiscoverViewModel
    @ObservedObject var workoutVM: WorkoutViewModel
    @ObservedObject var profileVM: ProfileViewModel

    @State private var showAddedConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                // Interactive 2-Phase Animated Demonstration Player
                ExerciseMotionPlayerView(exercise: exercise)

                // Quick Spec Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    StatPillView(
                        title: "Equipment",
                        value: exercise.formattedEquipment,
                        symbol: "dumbbell.fill",
                        color: AppTheme.brandAccent
                    )
                    StatPillView(
                        title: "Level",
                        value: exercise.level.displayName,
                        symbol: "chart.bar.fill",
                        color: AppTheme.accentColor(for: exercise.level)
                    )
                    StatPillView(
                        title: "Mechanic",
                        value: exercise.formattedMechanic,
                        symbol: "gearshape.2.fill",
                        color: AppTheme.indigo
                    )
                    StatPillView(
                        title: "Force",
                        value: exercise.formattedForce,
                        symbol: "bolt.fill",
                        color: AppTheme.heatOrange
                    )
                }

                // Target & Secondary Muscles
                VStack(alignment: .leading, spacing: 10) {
                    Text("Muscles Worked")
                        .font(.headline)

                    HStack(spacing: 8) {
                        ForEach(exercise.primaryMuscles, id: \.self) { muscle in
                            MuscleBadgeView(
                                text: "Primary · \(muscle.capitalized)",
                                color: AppTheme.accentColor(for: exercise.muscleGroup),
                                symbol: "target"
                            )
                        }
                    }

                    if !exercise.secondaryMuscles.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(exercise.secondaryMuscles, id: \.self) { sec in
                                    MuscleBadgeView(
                                        text: sec.capitalized,
                                        color: .secondary
                                    )
                                }
                            }
                        }
                    }
                }
                .fitnessCard()

                // Step-by-Step Execution Guide
                if !exercise.instructions.isEmpty {
                    VStack(alignment: .leading, spacing: 14) {
                        Label("Execution & Form Cues", systemImage: "list.number")
                            .font(.headline)

                        ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 24, height: 24)
                                    .background(AppTheme.brandAccent, in: Circle())

                                Text(step)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .fitnessCard()
                }

                // Primary Action Button
                Button {
                    if workoutVM.isSessionActive {
                        workoutVM.addExerciseToActiveSession(exercise)
                        showAddedConfirmation = true
                    } else {
                        workoutVM.startQuickSession(with: exercise)
                    }
                    HapticEngine.success(enabled: profileVM.preferences.hapticsEnabled)
                } label: {
                    Label(
                        workoutVM.isSessionActive ? "Add to Active Workout" : "Start Quick Workout With This Exercise",
                        systemImage: "play.fill"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.brandAccent)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
        }
        .background(AppTheme.surfaceGrouped)
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    discoverVM.toggleFavorite(exercise)
                    HapticEngine.impact(.light, enabled: profileVM.preferences.hapticsEnabled)
                } label: {
                    Image(systemName: discoverVM.isFavorite(exercise) ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(discoverVM.isFavorite(exercise) ? AppTheme.brandAccent : .primary)
                }
                .accessibilityLabel("Toggle saved exercise")
            }
        }
        .alert("Added to Workout", isPresented: $showAddedConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("\(exercise.name) has been added to your active session.")
        }
    }
}

#Preview {
    let container = AppContainer()
    return NavigationStack {
        ExerciseDetailView(
            exercise: .sample,
            discoverVM: container.discoverViewModel,
            workoutVM: container.workoutViewModel,
            profileVM: container.profileViewModel
        )
    }
}
