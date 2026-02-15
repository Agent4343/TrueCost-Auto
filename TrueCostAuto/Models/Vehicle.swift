import Foundation

struct Vehicle: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String = "New Vehicle"
    var createdAt: Date = .now

    // Pricing
    var vehiclePrice: Double = 38995
    var feesAndExtras: Double = 1499
    var downPayment: Double = 2000
    var tradeInValue: Double = 0

    // Loan
    var interestRate: Double = 6.99
    var loanTermMonths: Int = 84
    var salesTaxRate: Double = 15.0

    // Running Costs (monthly)
    var insurance: Double = 190
    var fuel: Double = 240
    var maintenance: Double = 60
    var tiresAndOther: Double = 30

    // Optional
    var monthlyIncome: Double = 7000
    var extraMonthlyPayment: Double = 0

    var amountFinanced: Double {
        let subtotal = vehiclePrice + feesAndExtras - downPayment - tradeInValue
        let tax = subtotal * (salesTaxRate / 100.0)
        return subtotal + tax
    }

    var totalRunningCosts: Double {
        insurance + fuel + maintenance + tiresAndOther
    }

    static let availableTerms = [24, 36, 48, 60, 72, 84, 96]

    static let example = Vehicle(
        name: "2024 Honda CR-V",
        vehiclePrice: 38995,
        feesAndExtras: 1499,
        downPayment: 2000,
        tradeInValue: 0,
        interestRate: 6.99,
        loanTermMonths: 84,
        salesTaxRate: 15.0,
        insurance: 190,
        fuel: 240,
        maintenance: 60,
        tiresAndOther: 30,
        monthlyIncome: 7000
    )
}

enum SmartScoreRating: String, Codable {
    case excellent = "Excellent"
    case reasonable = "Reasonable"
    case stretch = "Stretch"
    case risky = "Risky"
    case overextended = "Overextended"

    var description: String {
        switch self {
        case .excellent: return "Well within budget"
        case .reasonable: return "Manageable for most"
        case .stretch: return "Tight but doable"
        case .risky: return "Could cause stress"
        case .overextended: return "Likely unaffordable"
        }
    }
}

enum CurrencyRegion: String, Codable, CaseIterable {
    case cad = "CAD"
    case usd = "USD"

    var symbol: String {
        switch self {
        case .cad: return "CA$"
        case .usd: return "$"
        }
    }

    var defaultTaxRate: Double {
        switch self {
        case .cad: return 15.0
        case .usd: return 7.0
        }
    }
}
