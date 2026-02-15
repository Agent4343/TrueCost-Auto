import Foundation
import SwiftUI
import Combine

@Observable
final class VehicleViewModel {
    var vehicle: Vehicle = .example
    var result: CalculationResult?
    var showResults = false
    var isPro = false

    // Currency
    var currency: CurrencyRegion = .cad

    // Save toast
    var showSaveToast = false

    // Compare mode
    var compareVehicles: [Vehicle] = []
    var compareResults: [UUID: CalculationResult] = [:]

    init() {
        recalculate()
    }

    func recalculate() {
        result = CostCalculator.calculate(for: vehicle)
    }

    func reset() {
        vehicle = Vehicle()
        vehicle.name = "New Vehicle"
        showResults = false
        recalculate()
    }

    func loadVehicle(_ v: Vehicle) {
        vehicle = v
        recalculate()
        showResults = true
    }

    func setCurrency(_ region: CurrencyRegion) {
        currency = region
        vehicle.salesTaxRate = region.defaultTaxRate
        recalculate()
    }

    func saveVehicle(to store: VehicleStore) {
        store.save(vehicle)
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)

        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showSaveToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            withAnimation(.easeOut(duration: 0.3)) {
                self?.showSaveToast = false
            }
        }
    }

    func addToCompare(_ v: Vehicle) {
        guard compareVehicles.count < 3 else { return }
        if !compareVehicles.contains(where: { $0.id == v.id }) {
            compareVehicles.append(v)
            compareResults[v.id] = CostCalculator.calculate(for: v)
        }
    }

    func removeFromCompare(_ v: Vehicle) {
        compareVehicles.removeAll { $0.id == v.id }
        compareResults.removeValue(forKey: v.id)
    }

    func clearCompare() {
        compareVehicles.removeAll()
        compareResults.removeAll()
    }

    var currencySymbol: String {
        currency.symbol
    }

    var shareText: String {
        guard let r = result else { return "" }
        let sym = currencySymbol
        return """
        TrueCost Auto — \(vehicle.name)
        ================================
        True Monthly Cost: \(TCTheme.formatCurrency(r.trueMonthlyCost, symbol: sym))
        Loan Payment: \(TCTheme.formatCurrency(r.monthlyPayment, symbol: sym))/mo
        Running Costs: \(TCTheme.formatCurrency(vehicle.totalRunningCosts, symbol: sym))/mo
        Total Interest: \(TCTheme.formatCurrency(r.totalInterest, symbol: sym))
        Total Paid: \(TCTheme.formatCurrency(r.totalPaid, symbol: sym))
        5-Year Cost: \(TCTheme.formatCurrency(r.fiveYearCost, symbol: sym))
        Smart Score: \(r.smartScore.rawValue) (\(Int(r.smartScoreValue))/100)\(r.incomePercentage.map { " — \(String(format: "%.1f", $0))% of income" } ?? "")
        ================================
        Calculated with TrueCost Auto
        """
    }
}
