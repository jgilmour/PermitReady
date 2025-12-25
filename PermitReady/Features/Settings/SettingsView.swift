import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedState: StateInfo
    let allStates: [StateInfo]
    @State private var showStateSelection = false
    @State private var showOnboarding = false

    var body: some View {
        NavigationStack {
            List {
                // State Section
                Section {
                    Button(action: {
                        HapticManager.impact()
                        showStateSelection = true
                    }) {
                        HStack {
                            Label("State", systemImage: "map.fill")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(selectedState.name)
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Study Settings")
                }

                // Help Section
                Section {
                    Button(action: {
                        HapticManager.impact()
                        showOnboarding = true
                    }) {
                        Label("View Tutorial", systemImage: "book.circle.fill")
                            .foregroundStyle(.blue)
                    }
                } header: {
                    Text("Help")
                }

                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("App Icon")
                        Spacer()
                        Image("AppIconImage")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        HapticManager.impact()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showStateSelection) {
                StateSelectionView(selectedState: $selectedState, allStates: allStates)
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView(selectedState: $selectedState, allStates: allStates, onComplete: {})
            }
        }
    }
}

#Preview {
    SettingsView(selectedState: .constant(StateInfo.preview), allStates: [StateInfo.preview])
}
