import Foundation
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()

    // Product ID - must match App Store Connect configuration
    private let removeAdsProductID = "com.yourname.permitready.removeads"

    @Published var products: [Product] = []
    @Published var purchasedProductIDs = Set<String>()
    @Published var isLoading = false
    @Published var errorMessage: String?

    // UserDefaults key for ad-free status
    private let adFreeKey = "isAdFree"

    var isAdFree: Bool {
        // Check both UserDefaults and purchased products
        UserDefaults.standard.bool(forKey: adFreeKey) || purchasedProductIDs.contains(removeAdsProductID)
    }

    private var updates: Task<Void, Never>?

    private init() {
        // Start listening for transaction updates
        updates = observeTransactionUpdates()
    }

    deinit {
        updates?.cancel()
    }

    // MARK: - Product Loading

    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load products from App Store
            products = try await Product.products(for: [removeAdsProductID])

            // Check for existing purchases
            await updatePurchasedProducts()
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("❌ StoreManager: Failed to load products - \(error)")
        }

        isLoading = false
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                // Check transaction verification
                let transaction = try checkVerified(verification)

                // Update purchased products
                await updatePurchasedProducts()

                // Mark ad-free in UserDefaults for offline access
                UserDefaults.standard.set(true, forKey: adFreeKey)

                // Finish the transaction
                await transaction.finish()

                HapticManager.notification(.success)

            case .userCancelled:
                errorMessage = "Purchase cancelled"

            case .pending:
                errorMessage = "Purchase pending approval"

            @unknown default:
                errorMessage = "Unknown purchase result"
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            HapticManager.notification(.error)
            throw error
        }

        isLoading = false
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        isLoading = true
        errorMessage = nil

        do {
            // Sync with App Store
            try await AppStore.sync()

            // Update purchased products
            await updatePurchasedProducts()

            if isAdFree {
                UserDefaults.standard.set(true, forKey: adFreeKey)
                HapticManager.notification(.success)
            } else {
                errorMessage = "No purchases found to restore"
            }
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            HapticManager.notification(.error)
        }

        isLoading = false
    }

    // MARK: - Private Helpers

    private func updatePurchasedProducts() async {
        // Iterate through all transactions
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }

            if transaction.revocationDate == nil {
                purchasedProductIDs.insert(transaction.productID)
            } else {
                purchasedProductIDs.remove(transaction.productID)
            }
        }
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }

                if case .verified(let transaction) = result {
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Store Errors

enum StoreError: Error {
    case failedVerification
}

extension StoreError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        }
    }
}
