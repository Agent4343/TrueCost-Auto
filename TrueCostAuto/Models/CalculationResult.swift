import Foundation

struct CalculationResult: Equatable {
    let monthlyPayment: Double
    let biWeeklyPayment: Double
    let totalInterest: Double
    let totalPaid: Double
    let trueMonthlyCost: Double
    let fiveYearCost: Double
    let incomePercentage: Double?
    let smartScore: SmartScoreRating
    let smartScoreValue: Double

    // Extra payment scenario
    let monthsSavedWithExtra: Int
    let interestSavedWithExtra: Double
    let payoffMonthsWithExtra: Int

    // Amortization
    let amortizationSchedule: [AmortizationEntry]
}

struct AmortizationEntry: Identifiable, Equatable {
    let id: Int
    let month: Int
    let payment: Double
    let principal: Double
    let interest: Double
    let remainingBalance: Double
}

struct ComparisonDelta {
    let vehicleA: String
    let vehicleB: String
    let monthlyCostDiff: Double
    let totalCostDiff: Double
    let fiveYearDiff: Double
    let interestDiff: Double
}
