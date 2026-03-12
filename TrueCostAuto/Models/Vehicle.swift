import Foundation

struct Vehicle: Identifiable, Hashable {
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
    var warranty: Double = 0

    // Depreciation
    var depreciationRate: Double = 15.0

    // Fuel Estimator
    var useFuelEstimator: Bool = false
    var annualDistance: Double = 20000
    var fuelEfficiency: Double = 9.0
    var fuelPricePerUnit: Double = 1.65

    // Optional
    var monthlyIncome: Double = 7000
    var extraMonthlyPayment: Double = 0

    // Affordability / wizard
    var monthlyBudget: Double = 0

    var amountFinanced: Double {
        let subtotal = vehiclePrice + feesAndExtras - downPayment - tradeInValue
        let tax = subtotal * (salesTaxRate / 100.0)
        return subtotal + tax
    }

    var totalRunningCosts: Double {
        insurance + fuel + maintenance + tiresAndOther + warranty
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
        depreciationRate: 15.0,
        monthlyIncome: 7000
    )
}

// Backward-compatible Codable (preserves synthesized memberwise init)
extension Vehicle: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, createdAt
        case vehiclePrice, feesAndExtras, downPayment, tradeInValue
        case interestRate, loanTermMonths, salesTaxRate
        case insurance, fuel, maintenance, tiresAndOther, warranty
        case depreciationRate
        case useFuelEstimator, annualDistance, fuelEfficiency, fuelPricePerUnit
        case monthlyIncome, extraMonthlyPayment, monthlyBudget
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decode(UUID.self, forKey: .id)) ?? UUID()
        name = (try? c.decode(String.self, forKey: .name)) ?? "New Vehicle"
        createdAt = (try? c.decode(Date.self, forKey: .createdAt)) ?? .now
        vehiclePrice = (try? c.decode(Double.self, forKey: .vehiclePrice)) ?? 38995
        feesAndExtras = (try? c.decode(Double.self, forKey: .feesAndExtras)) ?? 1499
        downPayment = (try? c.decode(Double.self, forKey: .downPayment)) ?? 2000
        tradeInValue = (try? c.decode(Double.self, forKey: .tradeInValue)) ?? 0
        interestRate = (try? c.decode(Double.self, forKey: .interestRate)) ?? 6.99
        loanTermMonths = (try? c.decode(Int.self, forKey: .loanTermMonths)) ?? 84
        salesTaxRate = (try? c.decode(Double.self, forKey: .salesTaxRate)) ?? 15.0
        insurance = (try? c.decode(Double.self, forKey: .insurance)) ?? 190
        fuel = (try? c.decode(Double.self, forKey: .fuel)) ?? 240
        maintenance = (try? c.decode(Double.self, forKey: .maintenance)) ?? 60
        tiresAndOther = (try? c.decode(Double.self, forKey: .tiresAndOther)) ?? 30
        warranty = (try? c.decode(Double.self, forKey: .warranty)) ?? 0
        depreciationRate = (try? c.decode(Double.self, forKey: .depreciationRate)) ?? 15.0
        useFuelEstimator = (try? c.decode(Bool.self, forKey: .useFuelEstimator)) ?? false
        annualDistance = (try? c.decode(Double.self, forKey: .annualDistance)) ?? 20000
        fuelEfficiency = (try? c.decode(Double.self, forKey: .fuelEfficiency)) ?? 9.0
        fuelPricePerUnit = (try? c.decode(Double.self, forKey: .fuelPricePerUnit)) ?? 1.65
        monthlyIncome = (try? c.decode(Double.self, forKey: .monthlyIncome)) ?? 7000
        extraMonthlyPayment = (try? c.decode(Double.self, forKey: .extraMonthlyPayment)) ?? 0
        monthlyBudget = (try? c.decode(Double.self, forKey: .monthlyBudget)) ?? 0
    }
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

    var distanceUnit: String {
        switch self {
        case .cad: return "km"
        case .usd: return "mi"
        }
    }

    var fuelEfficiencyLabel: String {
        switch self {
        case .cad: return "L/100km"
        case .usd: return "MPG"
        }
    }

    var fuelPriceLabel: String {
        switch self {
        case .cad: return "$/L"
        case .usd: return "$/gal"
        }
    }

    var defaultAnnualDistance: Double {
        switch self {
        case .cad: return 20000
        case .usd: return 12000
        }
    }

    var defaultFuelEfficiency: Double {
        switch self {
        case .cad: return 9.0
        case .usd: return 28.0
        }
    }

    var defaultFuelPrice: Double {
        switch self {
        case .cad: return 1.65
        case .usd: return 3.50
        }
    }
}
