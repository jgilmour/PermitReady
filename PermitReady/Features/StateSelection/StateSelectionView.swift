import SwiftUI

struct StateSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedState: StateInfo
    let allStates: [StateInfo]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(allStates.sorted(by: { $0.name < $1.name })) { state in
                        StateRow(
                            state: state,
                            isSelected: selectedState.id == state.id,
                            action: {
                                HapticManager.selection()
                                selectedState = state
                                dismiss()
                            }
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Select Your State")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct StateRow: View {
    let state: StateInfo
    let isSelected: Bool
    let action: () -> Void
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main button
            Button(action: action) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(state.name)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        HStack {
                            Text("\(state.testQuestionCount) questions")
                            Text("•")
                            Text("\(state.passingPercentage)% to pass")
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

            // Requirements section (expandable)
            if !state.uniqueRequirements.isEmpty {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Label("Requirements", systemImage: "info.circle")
                            .font(.caption)
                            .foregroundStyle(.blue)

                        Spacer()

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.05))
                }

                if isExpanded {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(state.uniqueRequirements.enumerated()), id: \.offset) { _, requirement in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundStyle(.secondary)
                                Text(requirement)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    StateSelectionView(
        selectedState: .constant(StateInfo(
            id: "MA",
            name: "Massachusetts",
            minimumPermitAge: 16.0,
            testQuestionCount: 25,
            passingPercentage: 72,
            hasSplitTest: false,
            splitTestInfo: nil,
            uniqueRequirements: [
                "Parent/guardian must attend 2-hour driver education session",
                "Must hold permit for 6 months before road test",
                "40 hours supervised driving required (including 6 night hours)"
            ],
            timeLimitMinutes: 25
        )),
        allStates: [StateInfo.preview]
    )
}
