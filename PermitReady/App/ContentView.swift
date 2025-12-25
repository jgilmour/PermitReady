import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showQuiz = false
    @State private var showTest = false
    @State private var showProgress = false
    @State private var showCategorySelection = false
    @State private var showStateSelection = false
    @State private var showOnboarding = false
    @State private var showSettings = false
    @State private var quizID = UUID()
    @State private var testID = UUID()
    @State private var selectedState: StateInfo?
    @State private var allStates: [StateInfo] = []
    @State private var isLoadingStates = true
    @State private var requirementsExpanded = false

    @State private var stateService = StateService()
    private let questionService = QuestionService()

    private var currentState: StateInfo {
        selectedState ?? allStates.first { $0.id == "MA" } ?? allStates.first ?? StateInfo.preview
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoadingStates {
                    VStack(spacing: 24) {
                        PulsingAppIcon()
                        Text("Loading states...")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Compact header
                            HStack(spacing: 12) {
                                Image("AppIconImage")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("PermitReady")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text("Your path to passing the permit test")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)

                            // State info card (tappable)
                        VStack(alignment: .leading, spacing: 12) {
                            // Header with change button
                            Button(action: {
                                HapticManager.impact()
                                showStateSelection = true
                            }) {
                                HStack {
                                    Text(currentState.name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.primary)

                                    Spacer()

                                    HStack(spacing: 4) {
                                        Text("Change")
                                            .font(.subheadline)
                                            .foregroundStyle(.blue)
                                        Image(systemName: "chevron.right")
                                            .font(.subheadline)
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }

                            Divider()

                            // State info (non-tappable)
                            VStack(alignment: .leading, spacing: 8) {
                                InfoRow(label: "Test Questions", value: "\(currentState.testQuestionCount)")
                                InfoRow(label: "Passing Score", value: "\(currentState.passingPercentage)%")
                                InfoRow(label: "Minimum Age", value: "\(currentState.minimumPermitAge)")
                            }

                            // Show compact requirements (collapsed by default)
                            if !currentState.uniqueRequirements.isEmpty {
                                Divider()

                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        requirementsExpanded.toggle()
                                    }
                                }) {
                                    HStack {
                                        Label("\(currentState.uniqueRequirements.count) Requirements", systemImage: "exclamationmark.circle")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.orange)

                                        Spacer()

                                        Image(systemName: requirementsExpanded ? "chevron.up" : "chevron.down")
                                            .font(.caption2)
                                            .foregroundStyle(.orange)
                                    }
                                }
                                .buttonStyle(.plain)

                                if requirementsExpanded {
                                    VStack(alignment: .leading, spacing: 6) {
                                        ForEach(Array(currentState.uniqueRequirements.enumerated()), id: \.offset) { _, requirement in
                                            HStack(alignment: .top, spacing: 6) {
                                                Text("•")
                                                    .foregroundStyle(.secondary)
                                                    .font(.caption2)
                                                Text(requirement)
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                        }
                                    }
                                    .padding(.top, 8)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)

                        // Primary action (full width)
                        Button(action: {
                            HapticManager.impact()
                            testID = UUID()
                            showTest = true
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Take Practice Test")
                                    .fontWeight(.semibold)
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)

                        // Secondary action
                        Button(action: {
                            HapticManager.impact()
                            quizID = UUID()
                            showQuiz = true
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Practice Quiz")
                                    .fontWeight(.semibold)
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)

                        // Additional actions (horizontal row of compact buttons)
                        HStack(spacing: 12) {
                            Button(action: {
                                HapticManager.impact()
                                showCategorySelection = true
                            }) {
                                VStack(spacing: 6) {
                                    Image(systemName: "book.fill")
                                        .font(.title3)
                                    Text("Study by Category")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .multilineTextAlignment(.center)
                                }
                                .foregroundStyle(.orange)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.orange.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }

                            Button(action: {
                                HapticManager.impact()
                                showProgress = true
                            }) {
                                VStack(spacing: 6) {
                                    Image(systemName: "chart.bar.fill")
                                        .font(.title3)
                                    Text("View Progress")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundStyle(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        HapticManager.impact()
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.blue)
                    }
                }
            }
            .navigationDestination(isPresented: $showQuiz) {
                if let state = selectedState {
                    QuizView(stateInfo: state, mode: .practice)
                        .id(quizID)
                } else {
                    EmptyView()
                }
            }
            .navigationDestination(isPresented: $showTest) {
                if let state = selectedState {
                    QuizView(stateInfo: state, mode: .test)
                        .id(testID)
                } else {
                    EmptyView()
                }
            }
            .sheet(isPresented: $showProgress) {
                UserProgressView(stateInfo: currentState, modelContext: modelContext)
            }
            .sheet(isPresented: $showCategorySelection) {
                CategorySelectionView(stateInfo: currentState)
            }
            .sheet(isPresented: $showStateSelection) {
                StateSelectionView(
                    selectedState: Binding(
                        get: { selectedState ?? currentState },
                        set: { selectedState = $0 }
                    ),
                    allStates: allStates
                )
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(
                    selectedState: Binding(
                        get: { selectedState ?? currentState },
                        set: { selectedState = $0 }
                    ),
                    allStates: allStates
                )
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView(
                    selectedState: Binding(
                        get: { selectedState ?? currentState },
                        set: { selectedState = $0 }
                    ),
                    allStates: allStates,
                    onComplete: {
                        UserDefaults.standard.hasSeenOnboarding = true
                    }
                )
            }
            .task { @MainActor in
                await loadStates()
            }
            .onAppear {
                if !UserDefaults.standard.hasSeenOnboarding {
                    showOnboarding = true
                }
            }
        }
    }
    
    @MainActor
    private func loadStates() async {
        isLoadingStates = true
        do {
            allStates = try await stateService.loadAllStates(questionService: questionService)
            if selectedState == nil {
                selectedState = allStates.first { $0.id == "MA" } ?? allStates.first
            }
            isLoadingStates = false
        } catch {
            print("Failed to load states: \(error)")
            isLoadingStates = false
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}

#Preview {
    ContentView()
}
