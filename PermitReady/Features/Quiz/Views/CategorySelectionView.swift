import SwiftUI
import SwiftData

struct CategorySelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let stateInfo: StateInfo
    @State private var userProgress: UserProgress?
    @State private var availableCategories: [Question.QuestionCategory] = []
    @State private var isLoadingCategories = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.orange)

                        Text("Study by Category")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Focus on specific areas to improve your knowledge")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical)

                    // Categories
                    if isLoadingCategories {
                        ProgressView()
                            .padding()
                    } else {
                        VStack(spacing: 12) {
                            ForEach(availableCategories, id: \.self) { category in
                                NavigationLink {
                                    QuizView(
                                        stateInfo: stateInfo,
                                        category: category
                                    )
                                } label: {
                                    CategoryCard(
                                        category: category,
                                        mastery: userProgress?.categoryMastery[category.rawValue] ?? 0
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(stateInfo.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadUserProgress()
                loadAvailableCategories()
            }
        }
    }

    private func loadUserProgress() {
        let progressService = ProgressService()
        userProgress = try? progressService.getUserProgress(
            for: stateInfo.id,
            modelContext: modelContext
        )
    }

    private func loadAvailableCategories() {
        Task {
            do {
                let questionService = QuestionService()
                let categories = try await questionService.getAvailableCategories(for: stateInfo.id)
                await MainActor.run {
                    availableCategories = categories
                    isLoadingCategories = false
                }
            } catch {
                print("Error loading categories: \(error)")
                await MainActor.run {
                    availableCategories = []
                    isLoadingCategories = false
                }
            }
        }
    }
}

struct CategoryCard: View {
    let category: Question.QuestionCategory
    let mastery: Double

    var masteryColor: Color {
        if mastery >= 80 {
            return .green
        } else if mastery >= 60 {
            return .yellow
        } else if mastery > 0 {
            return .orange
        } else {
            return .gray
        }
    }

    var masteryLabel: String {
        if mastery >= 80 {
            return "Proficient"
        } else if mastery >= 60 {
            return "Learning"
        } else if mastery > 0 {
            return "Needs Practice"
        } else {
            return "Not Started"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.displayName)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(masteryLabel)
                        .font(.caption)
                        .foregroundStyle(masteryColor)
                }

                Spacer()

                if mastery > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "%.0f%%", mastery))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(masteryColor)

                        Text("Mastery")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(masteryColor)
                        .frame(width: geometry.size.width * (mastery / 100))
                }
            }
            .frame(height: 6)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    CategorySelectionView(
        stateInfo: StateInfo.preview
    )
    .modelContainer(for: [QuizAttempt.self, UserProgress.self])
}
