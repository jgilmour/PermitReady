import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedState: StateInfo
    let allStates: [StateInfo]
    @State private var showStateSelection = false
    @State private var showOnboarding = false
    @StateObject private var storeManager = StoreManager.shared

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

                // Premium Section
                Section {
                    if storeManager.isAdFree {
                        // Already purchased
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Ad-Free Active")
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(.primary)
                    } else {
                        // Purchase option
                        if let product = storeManager.products.first {
                            Button(action: {
                                HapticManager.impact()
                                Task {
                                    try? await storeManager.purchase(product)
                                }
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Remove Ads")
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Text("Enjoy uninterrupted studying forever")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(product.displayPrice)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.green)
                                }
                            }
                            .disabled(storeManager.isLoading)
                        } else {
                            if storeManager.isLoading {
                                HStack {
                                    ProgressView()
                                    Text("Loading...")
                                        .foregroundStyle(.secondary)
                                }
                            } else {
                                Text("Products unavailable")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    // Restore purchases button (always visible for App Store compliance)
                    Button(action: {
                        HapticManager.impact()
                        Task {
                            await storeManager.restorePurchases()
                        }
                    }) {
                        HStack {
                            Text("Restore Purchases")
                                .font(storeManager.isAdFree ? .caption : .body)
                                .foregroundStyle(storeManager.isAdFree ? Color.secondary : Color.blue)
                            if storeManager.isLoading {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(storeManager.isLoading)

                    // Error message (hide user cancellation errors)
                    if let error = storeManager.errorMessage {
                        if !error.lowercased().contains("cancel") {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                } header: {
                    Text("Premium")
                } footer: {
                    Text("One-time purchase. Removes all ads permanently.")
                        .font(.caption)
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

                    // Privacy Policy link
                    Link(destination: URL(string: "https://techsmog.com/permitready/privacy.html")!) {
                        HStack {
                            Label("Privacy Policy", systemImage: "hand.raised.fill")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Terms of Service link
                    Link(destination: URL(string: "https://techsmog.com/permitready/terms.html")!) {
                        HStack {
                            Label("Terms of Service", systemImage: "doc.text.fill")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("About")
                }

                // Legal Disclaimers Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Important Notice")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text("This app is not affiliated with, endorsed by, or sponsored by any Department of Motor Vehicles (DMV), Registry of Motor Vehicles (RMV), or government agency.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Practice questions are for informational and educational purposes only and do not guarantee passing the official permit exam.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("All content is derived from publicly available state driver handbooks and manuals. Question formats and content may differ from actual state exams.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Always verify current requirements and regulations with your state's official DMV/RMV website before taking the official exam.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Legal Disclaimers")
                } footer: {
                    Text("© 2025 PermitReady. All rights reserved.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
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
            .task {
                // Load products when view appears
                await storeManager.loadProducts()
            }
        }
    }
}

#Preview {
    SettingsView(selectedState: .constant(StateInfo.preview), allStates: [StateInfo.preview])
}
