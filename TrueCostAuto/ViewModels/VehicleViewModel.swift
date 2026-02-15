import Foundation
import SwiftUI
import Combine

@Observable
final class VehicleViewModel {
    var vehicle: Vehicle = .example
    var result: CalculationResult?
    var showResults = false
    var isPro = false

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

    var shareText: String {
        guard let r = result else { return "" }
        return """
        TrueCost Auto - \(vehicle.name)
        --------------------------------
        True Monthly Cost: \(TCTheme.formatCurrency(r.trueMonthlyCost))
        Loan Payment: \(TCTheme.formatCurrency(r.monthlyPayment))/mo
        Running Costs: \(TCTheme.formatCurrency(vehicle.totalRunningCosts))/mo
        Total Interest: \(TCTheme.formatCurrency(r.totalInterest))
        Total Paid: \(TCTheme.formatCurrency(r.totalPaid))
        5-Year Cost: \(TCTheme.formatCurrency(r.fiveYearCost))
        Smart Score: \(r.smartScore.rawValue)\(r.incomePercentage.map { " (\(String(format: "%.1f", $0))% of income)" } ?? "")
        --------------------------------
        Calculated with TrueCost Auto
        """
    }
}
