import Foundation

// MARK: - Verdict

/// Top-level verdict for a deal, computed from the DealFit Index.
enum VerdictRating: String, Codable {
    case good = "Good Deal"
    case caution = "Caution"
    case notRecommended = "Not Recommended"

    var icon: String {
        switch self {
        case .good: return "checkmark.seal.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .notRecommended: return "xmark.octagon.fill"
        }
    }

    var summary: String {
        switch self {
        case .good: return "This deal looks healthy for your budget."
        case .caution: return "This deal is manageable but worth watching."
        case .notRecommended: return "This deal may put financial strain on your budget."
        }
    }
}

// MARK: - Affordability Result

/// Reverse-affordability calculation result.
struct AffordabilityResult {
    /// Maximum all-in monthly vehicle cost the user can afford.
    let targetMonthlyCost: Double
    /// Monthly running costs (insurance + fuel + maintenance + other).
    let estimatedRunningCosts: Double
    /// Maximum monthly loan payment available after running costs.
    let maxMonthlyLoanPayment: Double
    /// Maximum financed amount given APR, term, and max payment.
    let maxFinancedAmount: Double
    /// Maximum suggested vehicle price (financed + down payment + trade-in, before tax/fees).
    let maxVehiclePrice: Double
    /// Percentage of income consumed if income provided.
    let incomePercent: Double?
}

// MARK: - CalculationResult

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

    // DealFit Index (branded label for Smart Score)
    var dealFitValue: Double { smartScoreValue }
    var verdict: VerdictRating {
        switch smartScoreValue {
        case 70...100: return .good
        case 40..<70:  return .caution
        default:       return .notRecommended
        }
    }

    // Top cost drivers (sorted by monthly $ amount, descending)
    var costDrivers: [CostDriver] {
        let total = max(trueMonthlyCost, 1)
        var drivers: [CostDriver] = []
        if monthlyPayment > 0 {
            drivers.append(CostDriver(label: "Loan Payment", monthlyCost: monthlyPayment, pct: monthlyPayment / total))
        }
        if monthlyDepreciation > 0 {
            drivers.append(CostDriver(label: "Depreciation", monthlyCost: monthlyDepreciation, pct: monthlyDepreciation / total))
        }
        return drivers.sorted { $0.monthlyCost > $1.monthlyCost }
    }

    // Depreciation
    let monthlyDepreciation: Double
    let fiveYearDepreciation: Double

    // Daily cost
    let dailyCost: Double

    // Extra payment scenario
    let monthsSavedWithExtra: Int
    let interestSavedWithExtra: Double
    let payoffMonthsWithExtra: Int

    // Amortization
    let amortizationSchedule: [AmortizationEntry]

    // Year-by-year projection
    let yearProjections: [YearProjection]
}

struct AmortizationEntry: Identifiable, Equatable {
    let id: Int
    let month: Int
    let payment: Double
    let principal: Double
    let interest: Double
    let remainingBalance: Double
}

struct YearProjection: Identifiable, Equatable {
    let id: Int
    let year: Int
    let vehicleValue: Double
    let cumulativePaid: Double
    let loanBalance: Double
    let equity: Double
}

struct ComparisonDelta {
    let vehicleA: String
    let vehicleB: String
    let monthlyCostDiff: Double
    let totalCostDiff: Double
    let fiveYearDiff: Double
    let interestDiff: Double
}

// MARK: - CostDriver

struct CostDriver: Identifiable {
    var id: String { label }
    let label: String
    let monthlyCost: Double
    let pct: Double
}
