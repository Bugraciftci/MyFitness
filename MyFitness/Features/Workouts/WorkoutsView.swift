//
//  WorkoutsView.swift
//  MyFitness
//

import Charts
import SwiftUI

struct WorkoutsView: View {
    @ObservedObject var workoutVM: WorkoutViewModel
    @ObservedObject var discoverVM: DiscoverViewModel
    @ObservedObject var profileVM: ProfileViewModel

    @State private var selectedPlan: WorkoutPlan?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    weeklyProgressSection
                    curatedSplitsSection
                    recentSessionsSection
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
            }
            .background(AppTheme.surfaceGrouped)
            .navigationTitle("Workouts")
            .sheet(item: $selectedPlan) { plan in
                PlanDetailSheet(
                    plan: plan,
                    discoverVM: discoverVM,
                    workoutVM: workoutVM,
                    profileVM: profileVM
                )
            }
        }
    }

    // MARK: - Weekly Volume Chart + Rings

    private var weeklyProgressSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 16) {
                ActivityRingView(
                    progress: Double(workoutVM.sessionsThisWeekCount) / Double(max(1, profileVM.preferences.weeklyWorkoutGoal)),
                    color: AppTheme.energyGreen,
                    lineWidth: 10,
                    size: 76,
                    centerTitle: "\(workoutVM.sessionsThisWeekCount)/\(profileVM.preferences.weeklyWorkoutGoal)",
                    centerSubtitle: "Weekly"
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text("Weekly Training Load")
                        .font(.headline)
                    Text("Total Volume: \(profileVM.preferences.weightUnit.formatted(workoutVM.totalLifetimeVolumeKg))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(workoutVM.completedSessions.count) completed sessions")
                        .font(.caption)
                        .foregroundStyle(AppTheme.brandAccent)
                }
                Spacer()
            }

            Chart(workoutVM.weeklyVolumeChartData) { point in
                BarMark(
                    x: .value("Day", point.dayLabel),
                    y: .value("Volume", profileVM.preferences.weightUnit.convert(fromKg: point.volumeKg))
                )
                .foregroundStyle(
                    point.volumeKg > 0 ? AppTheme.brandAccent.gradient : Color.secondary.opacity(0.25).gradient
                )
                .cornerRadius(6)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 140)
        }
        .fitnessCard(cornerRadius: AppTheme.Radius.lg)
    }

    // MARK: - Curated Splits

    private var curatedSplitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Structured Programs")
                .font(.headline)

            ForEach(workoutVM.curatedPlans) { plan in
                Button {
                    selectedPlan = plan
                    HapticEngine.impact(.light, enabled: profileVM.preferences.hapticsEnabled)
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(plan.title)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text("\(plan.daysPerWeek) days/week · ~\(plan.estimatedMinutes) min")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            MuscleBadgeView(
                                text: plan.level.displayName,
                                color: AppTheme.accentColor(for: plan.level)
                            )
                        }

                        Text(plan.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: 6) {
                            ForEach(plan.focusMuscles) { muscle in
                                MuscleBadgeView(
                                    text: muscle.rawValue,
                                    color: AppTheme.accentColor(for: muscle)
                                )
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .fitnessCard()
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Recent History

    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent History")
                .font(.headline)

            if workoutVM.completedSessions.isEmpty {
                ContentUnavailableView(
                    "No Logged Workouts Yet",
                    systemImage: "dumbbell",
                    description: Text("Pick a structured program above or open any exercise to log sets, weights, and 1RM progress.")
                )
                .padding(.vertical, 16)
            } else {
                ForEach(workoutVM.completedSessions.prefix(10)) { session in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.title)
                                .font(.subheadline.weight(.bold))
                            Text(session.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(profileVM.preferences.weightUnit.formatted(session.totalVolumeKg))
                                .font(.subheadline.weight(.bold))
                                .monospacedDigit()
                                .foregroundStyle(AppTheme.brandAccent)
                            Text("\(session.totalCompletedSets) sets · \(session.durationSeconds / 60)m")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .fitnessCard(cornerRadius: AppTheme.Radius.sm, padding: 14)
                }
            }
        }
    }
}

private struct PlanDetailSheet: View {
    let plan: WorkoutPlan
    @ObservedObject var discoverVM: DiscoverViewModel
    @ObservedObject var workoutVM: WorkoutViewModel
    @ObservedObject var profileVM: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(plan.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("\(plan.daysPerWeek) Days / Week · \(plan.level.displayName)")
                }

                Section("Select a Training Day to Launch") {
                    ForEach(plan.days) { day in
                        let exercises = discoverVM.exercises(for: day.targetMuscles, limitPerMuscle: 2)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(day.name)
                                        .font(.headline)
                                    Text("\(day.focus) · \(day.prescribedSets) sets × \(day.targetRepRange) reps")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button("Start") {
                                    dismiss()
                                    workoutVM.startSession(
                                        title: "\(plan.title) — \(day.name)",
                                        exercises: exercises,
                                        setsPerExercise: day.prescribedSets
                                    )
                                    HapticEngine.success(enabled: profileVM.preferences.hapticsEnabled)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(AppTheme.brandAccent)
                                .controlSize(.small)
                            }

                            if !exercises.isEmpty {
                                Text(exercises.map(\.name).joined(separator: " • "))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(plan.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
