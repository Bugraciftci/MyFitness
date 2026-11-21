//
//  DiscoverView.swift
//  MyFitness
//

import SwiftUI

struct DiscoverView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    @ObservedObject var workoutVM: WorkoutViewModel
    @ObservedObject var profileVM: ProfileViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    heroOverviewCard
                    muscleGroupsCarousel
                    equipmentAndLevelFilters
                    exerciseCatalogSection
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.top, AppTheme.Spacing.sm)
                .padding(.bottom, AppTheme.Spacing.lg)
            }
            .background(AppTheme.surfaceGrouped)
            .navigationTitle("MyFitness")
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search 800+ exercises, muscles, equipment"
            )
            .refreshable {
                await viewModel.refreshCatalog()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isSyncingLiveCatalog {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Button {
                            Task { await viewModel.refreshCatalog() }
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.subheadline.weight(.semibold))
                        }
                        .accessibilityLabel("Sync live exercise library")
                    }
                }
            }
            .navigationDestination(for: Exercise.self) { exercise in
                ExerciseDetailView(
                    exercise: exercise,
                    discoverVM: viewModel,
                    workoutVM: workoutVM,
                    profileVM: profileVM
                )
            }
        }
    }

    // MARK: - Hero Card

    private var heroOverviewCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(viewModel.dataSource == .liveGitHub ? AppTheme.energyGreen : AppTheme.heatOrange)
                        .frame(width: 7, height: 7)
                    Text(viewModel.dataSource.rawValue)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Text("\(viewModel.allExercises.count) Exercises Ready")
                    .font(.system(.title3, design: .rounded).weight(.bold))

                Text("Interactive 2-phase form demos powered by Open Exercise DB.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 4)

            ActivityRingView(
                progress: Double(workoutVM.sessionsThisWeekCount) / Double(max(1, profileVM.preferences.weeklyWorkoutGoal)),
                color: AppTheme.energyGreen,
                lineWidth: 9,
                size: 70,
                centerTitle: "\(workoutVM.sessionsThisWeekCount)/\(profileVM.preferences.weeklyWorkoutGoal)",
                centerSubtitle: "Week"
            )
        }
        .fitnessCard(cornerRadius: AppTheme.Radius.lg, padding: AppTheme.Spacing.md)
    }

    // MARK: - Muscle Group Carousel

    private var muscleGroupsCarousel: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Text("Target Muscles")
                    .font(.headline)
                Spacer()
                if viewModel.selectedMuscle != nil {
                    Button("Show All") {
                        withAnimation(.snappy) {
                            viewModel.selectedMuscle = nil
                        }
                        HapticEngine.impact(.light, enabled: profileVM.preferences.hapticsEnabled)
                    }
                    .font(.caption.weight(.semibold))
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(MuscleGroup.allCases) { muscle in
                        let isSelected = viewModel.selectedMuscle == muscle
                        Button {
                            withAnimation(.snappy) {
                                viewModel.selectedMuscle = isSelected ? nil : muscle
                            }
                            HapticEngine.impact(.light, enabled: profileVM.preferences.hapticsEnabled)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: muscle.symbolName)
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(isSelected ? .white : AppTheme.accentColor(for: muscle))
                                        .frame(width: 36, height: 36)
                                        .background(
                                            isSelected
                                                ? Color.white.opacity(0.22)
                                                : AppTheme.accentColor(for: muscle).opacity(0.14),
                                            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        )
                                    Spacer()
                                    Text("\(viewModel.count(for: muscle))")
                                        .font(.caption.weight(.bold))
                                        .monospacedDigit()
                                        .foregroundStyle(isSelected ? .white.opacity(0.9) : .secondary)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(muscle.rawValue)
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(isSelected ? .white : .primary)
                                    Text(muscle.subtitle)
                                        .font(.caption2)
                                        .foregroundStyle(isSelected ? .white.opacity(0.85) : .secondary)
                                        .lineLimit(1)
                                }
                            }
                            .padding(12)
                            .frame(width: 148, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                                    .fill(isSelected ? AnyShapeStyle(AppTheme.gradient(for: muscle)) : AnyShapeStyle(AppTheme.surfaceSecondary))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                                    .strokeBorder(
                                        isSelected ? Color.clear : Color.primary.opacity(0.06),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - Equipment & Difficulty Filters

    private var equipmentAndLevelFilters: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(EquipmentFilter.allCases) { eq in
                        let selected = viewModel.selectedEquipment == eq
                        Button {
                            withAnimation(.snappy) { viewModel.selectedEquipment = eq }
                            HapticEngine.impact(.soft, enabled: profileVM.preferences.hapticsEnabled)
                        } label: {
                            Text(eq.rawValue)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .foregroundStyle(selected ? .white : .primary)
                                .background(
                                    selected ? AppTheme.brandAccent : AppTheme.surfaceSecondary,
                                    in: Capsule()
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            HStack(spacing: 8) {
                ForEach(DifficultyLevel.allCases) { level in
                    let selected = viewModel.selectedDifficulty == level
                    Button {
                        withAnimation(.snappy) {
                            viewModel.selectedDifficulty = selected ? nil : level
                        }
                        HapticEngine.impact(.soft, enabled: profileVM.preferences.hapticsEnabled)
                    } label: {
                        Text(level.displayName)
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .foregroundStyle(selected ? .white : AppTheme.accentColor(for: level))
                            .background(
                                selected ? AppTheme.accentColor(for: level) : AppTheme.accentColor(for: level).opacity(0.12),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                if viewModel.hasActiveFilters {
                    Button("Reset") {
                        withAnimation(.snappy) { viewModel.clearFilters() }
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.crimson)
                }
            }
        }
    }

    // MARK: - Exercise List

    private var exerciseCatalogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(viewModel.selectedMuscle?.rawValue ?? "All Exercises")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.filteredExercises.count) results")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            if viewModel.filteredExercises.isEmpty {
                ContentUnavailableView {
                    Label("No Matching Exercises", systemImage: "magnifyingglass")
                } description: {
                    Text("Try clearing your equipment or difficulty filters to explore all exercises.")
                } actions: {
                    Button("Clear Filters") {
                        viewModel.clearFilters()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.vertical, 28)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredExercises) { exercise in
                        NavigationLink(value: exercise) {
                            ExerciseRowCard(
                                exercise: exercise,
                                isFavorite: viewModel.isFavorite(exercise),
                                onToggleFavorite: {
                                    viewModel.toggleFavorite(exercise)
                                    HapticEngine.impact(.light, enabled: profileVM.preferences.hapticsEnabled)
                                }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct ExerciseRowCard: View {
    let exercise: Exercise
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            AsyncCachedImage(
                url: exercise.primaryImageURL,
                contentMode: .fill,
                fallbackSymbol: exercise.muscleGroup.symbolName
            )
            .frame(width: 78, height: 78)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(exercise.name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 6) {
                    MuscleBadgeView(
                        text: exercise.muscleGroup.rawValue,
                        color: AppTheme.accentColor(for: exercise.muscleGroup)
                    )
                    MuscleBadgeView(
                        text: exercise.formattedEquipment,
                        color: .secondary
                    )
                }

                HStack(spacing: 8) {
                    Label(exercise.level.displayName, systemImage: "chart.bar.fill")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(AppTheme.accentColor(for: exercise.level))

                    if exercise.images.count >= 2 {
                        Label("2-Phase Demo", systemImage: "play.circle.fill")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer(minLength: 4)

            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(isFavorite ? AppTheme.brandAccent : .secondary)
                    .frame(width: 34, height: 34)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isFavorite ? "Remove from saved" : "Save exercise")
        }
        .fitnessCard(cornerRadius: AppTheme.Radius.md, padding: 12)
    }
}
