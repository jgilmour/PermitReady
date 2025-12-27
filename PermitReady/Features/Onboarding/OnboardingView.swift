import SwiftUI

struct OnboardingView: View {
    @Binding var selectedState: StateInfo
    let allStates: [StateInfo]
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0

    var onComplete: () -> Void

    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                // Screen 1: Welcome
                WelcomeScreen()
                    .tag(0)

                // Screen 2: State Selection
                StatePickerScreen(
                    selectedState: $selectedState,
                    currentPage: $currentPage,
                    allStates: allStates
                )
                    .tag(1)

                // Screen 3: Study Modes
                StudyModesScreen()
                    .tag(2)

                // Screen 4: Learning Tools
                LearningToolsScreen()
                    .tag(3)

                // Screen 5: Progress & Get Started
                FinalScreen(onGetStarted: {
                    onComplete()
                    dismiss()
                })
                .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            // Skip button overlay (only on screens 3 & 4)
            if currentPage == 2 || currentPage == 3 {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            onComplete()
                            dismiss()
                        }) {
                            Text("Skip")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.blue)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                        }
                    }
                    .padding()
                    Spacer()
                }
            }
        }
        .interactiveDismissDisabled()
    }
}

// MARK: - Welcome Screen
struct WelcomeScreen: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image("AppIconImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)

            VStack(spacing: 16) {
                Text("Welcome to PermitReady!")
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)

                Text("Your friendly companion to ace the permit test")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            Text("Swipe to continue")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 40)
        }
        .padding()
    }
}

// MARK: - State Picker Screen
struct StatePickerScreen: View {
    @Binding var selectedState: StateInfo
    @Binding var currentPage: Int
    let allStates: [StateInfo]

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "map.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)

                Text("Pick Your State")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)

                Text("Practice with the specific requirements for your state's official permit test")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 40)

            // State List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(allStates.sorted(by: { $0.name < $1.name })) { state in
                        OnboardingStateRow(
                            state: state,
                            isSelected: selectedState.id == state.id,
                            action: {
                                HapticManager.selection()
                                selectedState = state
                                // Auto-advance after selection
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation {
                                        currentPage = 2
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 60)
        }
    }
}

// MARK: - Onboarding State Row
struct OnboardingStateRow: View {
    let state: StateInfo
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main selection button
            Button(action: action) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(state.name)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        HStack(spacing: 4) {
                            Image(systemName: "doc.text")
                                .font(.caption2)
                            Text("Test: \(state.testQuestionCount) Qs")
                            Text("•")
                            Image(systemName: "checkmark.circle")
                                .font(.caption2)
                            Text("Pass: \(state.passingPercentage)%")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.title3)
                    }
                }
                .padding()
                .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            }

            // Show requirements when selected
            if isSelected && !state.uniqueRequirements.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                        Text("Requirements for \(state.name)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                    .padding(.top, 4)

                    ForEach(Array(state.uniqueRequirements.prefix(3).enumerated()), id: \.offset) { _, requirement in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                            Text(requirement)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    if state.uniqueRequirements.count > 3 {
                        Text("and \(state.uniqueRequirements.count - 3) more...")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                            .italic()
                            .padding(.leading, 12)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Study Modes Screen
struct StudyModesScreen: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "book.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            VStack(spacing: 16) {
                Text("Two Ways to Practice")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)

                Text("Choose the mode that fits your needs")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            VStack(spacing: 16) {
                // Practice Quiz Card
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.blue)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Practice Quiz")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("Learn mode. No timer, instant feedback on every question.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
                .padding()
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Practice Test Card
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: "timer")
                        .font(.system(size: 40))
                        .foregroundStyle(.green)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Practice Test")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("Exam mode. Timed simulation of the real test.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
                .padding()
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Learning Tools Screen
struct LearningToolsScreen: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "lightbulb.fill")
                .font(.system(size: 80))
                .foregroundStyle(.orange)

            VStack(spacing: 16) {
                Text("Smart Study Tools")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)

                Text("We've got features to help you master every topic")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            VStack(spacing: 16) {
                // Study by Category
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.orange)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Study by Category")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("Focus on topics like Road Signs or Traffic Laws")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
                .padding()
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Missed Questions
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.blue)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Review Mistakes")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("Learn from questions you missed with explanations")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
                .padding()
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Final Screen
struct FinalScreen: View {
    var onGetStarted: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            VStack(spacing: 16) {
                Text("Track Your Progress")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)

                Text("Watch your mastery grow with every quiz. See your streaks, scores, and improvement over time!")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            VStack(spacing: 12) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.yellow)

                Text("You're ready to crush it!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Let's get you that permit")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 20)

            Button(action: onGetStarted) {
                HStack {
                    Text("Get Started")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)

            // Ad-free mention
            Text("PermitReady is free with ads. Remove ads anytime from Settings for $1.99")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 8)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingView(
        selectedState: .constant(StateInfo(
            id: "MA",
            name: "Massachusetts",
            minimumPermitAge: 16.0,
            testQuestionCount: 25,
            passingPercentage: 72,
            hasSplitTest: false,
            splitTestInfo: nil,
            uniqueRequirements: [],
            timeLimitMinutes: 25
        )),
        allStates: [],
        onComplete: {}
    )
}
