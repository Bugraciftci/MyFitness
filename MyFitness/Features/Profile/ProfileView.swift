//
//  ProfileView.swift
//  MyFitness
//

import Charts
import SwiftUI

struct ProfileView: View {
    @ObservedObject var profileVM: ProfileViewModel
    @ObservedObject var workoutVM: WorkoutViewModel
    @ObservedObject var discoverVM: DiscoverViewModel

    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                // Summary Stats Section
                Section("Training Overview") {
                    HStack(spacing: 10) {
                        StatPillView(
                            title: "Workouts",
                            value: "\(workoutVM.completedSessions.count)",
                            symbol: "flame.fill",
                            color: AppTheme.heatOrange
                        )
                        StatPillView(
                            title: "Lifetime Vol.",
                            value: profileVM.preferences.weightUnit.formatted(workoutVM.totalLifetimeVolumeKg),
                            symbol: "scalemass.fill",
                            color: AppTheme.brandAccent
                        )
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)

                    let distribution = profileVM.muscleDistribution(from: workoutVM.completedSessions)
                    if !distribution.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Completed Sets by Muscle Group")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Chart(distribution) { item in
                                BarMark(
                                    x: .value("Sets", item.completedSets),
                                    y: .value("Muscle", item.muscle.rawValue)
                                )
                                .foregroundStyle(AppTheme.accentColor(for: item.muscle).gradient)
                                .cornerRadius(5)
                            }
                            .frame(height: CGFloat(max(120, distribution.count * 28)))
                        }
                        .padding(.vertical, 6)
                    }
                }

                // Preferences Section
                Section("Training Preferences") {
                    Picker("Weight Unit", selection: $profileVM.preferences.weightUnit) {
                        ForEach(WeightUnit.allCases) { unit in
                            Text(unit.rawValue.uppercased()).tag(unit)
                        }
                    }

                    Stepper(
                        "Weekly Goal: \(profileVM.preferences.weeklyWorkoutGoal) workouts",
                        value: $profileVM.preferences.weeklyWorkoutGoal,
                        in: 1...7
                    )

                    Stepper(
                        "Default Rest Timer: \(profileVM.preferences.defaultRestSeconds)s",
                        value: $profileVM.preferences.defaultRestSeconds,
                        in: 30...240,
                        step: 15
                    )

                    Picker("Appearance", selection: $profileVM.preferences.appearance) {
                        ForEach(AppAppearance.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }

                    Toggle("Haptic Feedback", isOn: $profileVM.preferences.hapticsEnabled)
                }

                // Data Attribution
                Section("Exercise Database & Architecture") {
                    HStack {
                        Text("Active Catalog")
                        Spacer()
                        Text("\(discoverVM.allExercises.count) exercises")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Data Source")
                        Spacer()
                        Text("yuhonas/free-exercise-db (Public Domain)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Reset
                Section {
                    Button("Reset All Workouts & Saved Data", role: .destructive) {
                        showResetConfirmation = true
                    }
                }
            }
            .navigationTitle("Profile & Settings")
            .alert("Reset All Local Data?", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    profileVM.resetAllData()
                    workoutVM.reloadFromStore()
                    discoverVM.reloadFavoritesFromStore()
                }
            } message: {
                Text("This clears your logged sessions, saved exercises, and preferences.")
            }
        }
    }
}
