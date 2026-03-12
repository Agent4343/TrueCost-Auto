import StoreKit
import Foundation

/// Manages the single non-consumable one-time unlock for DealFit Pro features.
@Observable
final class StoreKitManager {

    static let proProductID = "com.truecost.auto.dealfit_pro"
    private static let unlockedKey = "truecost_pro_unlocked"

    var isPro: Bool = false
    var product: Product?
    var isPurchasing: Bool = false
    var errorMessage: String?

    init() {
        isPro = UserDefaults.standard.bool(forKey: Self.unlockedKey)
        Task { await loadProducts() }
    }

    @MainActor
    func loadProducts() async {
        do {
            let products = try await Product.products(for: [Self.proProductID])
            product = products.first
            await verifyExistingPurchases()
        } catch {
            // Products unavailable in simulator or sandbox without StoreKit config — graceful no-op
        }
    }

    @MainActor
    func purchase() async {
        guard let product else { return }
        isPurchasing = true
        errorMessage = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    unlock()
                case .unverified:
                    errorMessage = "Purchase could not be verified. Please try again."
                }
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isPurchasing = false
    }

    @MainActor
    func restore() async {
        isPurchasing = true
        do {
            try await AppStore.sync()
            await verifyExistingPurchases()
        } catch {
            errorMessage = error.localizedDescription
        }
        isPurchasing = false
    }

    private func verifyExistingPurchases() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.proProductID {
                await MainActor.run { unlock() }
            }
        }
    }

    private func unlock() {
        isPro = true
        UserDefaults.standard.set(true, forKey: Self.unlockedKey)
    }
}
