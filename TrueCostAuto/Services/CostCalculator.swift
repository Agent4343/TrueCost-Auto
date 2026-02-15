import Foundation

struct CostCalculator {

    static func calculate(for vehicle: Vehicle) -> CalculationResult {
        let principal = vehicle.amountFinanced
        let monthlyRate = (vehicle.interestRate / 100.0) / 12.0
        let n = Double(vehicle.loanTermMonths)

        // Monthly payment using standard amortization formula
        let monthlyPayment: Double
        if monthlyRate > 0 {
            monthlyPayment = principal * (monthlyRate * pow(1 + monthlyRate, n)) / (pow(1 + monthlyRate, n) - 1)
        } else {
            monthlyPayment = n > 0 ? principal / n : 0
        }

        let biWeeklyPayment = monthlyPayment * 12.0 / 26.0
        let totalPaidOnLoan = monthlyPayment * n
        let totalInterest = totalPaidOnLoan - principal

        // True monthly cost
        let trueMonthlyCost = monthlyPayment + vehicle.totalRunningCosts

        // 5-year cost = 60 months of true cost, or full loan if shorter
        let fiveYearMonths = min(60.0, n)
        let fiveYearLoan = monthlyPayment * fiveYearMonths
        let fiveYearRunning = vehicle.totalRunningCosts * 60.0
        let fiveYearCost = fiveYearLoan + fiveYearRunning + vehicle.downPayment + vehicle.tradeInValue

        // Income percentage
        let incomePercentage: Double?
        if vehicle.monthlyIncome > 0 {
            incomePercentage = (trueMonthlyCost / vehicle.monthlyIncome) * 100.0
        } else {
            incomePercentage = nil
        }

        // Smart Score
        let (smartScore, smartScoreValue) = calculateSmartScore(
            trueMonthlyCost: trueMonthlyCost,
            monthlyPayment: monthlyPayment,
            income: vehicle.monthlyIncome,
            totalInterest: totalInterest,
            principal: principal,
            termMonths: vehicle.loanTermMonths
        )

        // Extra payment scenario
        let (monthsSaved, interestSaved, payoffMonths) = calculateExtraPayment(
            principal: principal,
            monthlyRate: monthlyRate,
            basePayment: monthlyPayment,
            extraPayment: vehicle.extraMonthlyPayment,
            originalTerm: vehicle.loanTermMonths
        )

        // Amortization schedule
        let schedule = buildAmortization(
            principal: principal,
            monthlyRate: monthlyRate,
            payment: monthlyPayment,
            termMonths: vehicle.loanTermMonths
        )

        return CalculationResult(
            monthlyPayment: monthlyPayment,
            biWeeklyPayment: biWeeklyPayment,
            totalInterest: totalInterest,
            totalPaid: totalPaidOnLoan + vehicle.downPayment,
            trueMonthlyCost: trueMonthlyCost,
            fiveYearCost: fiveYearCost,
            incomePercentage: incomePercentage,
            smartScore: smartScore,
            smartScoreValue: smartScoreValue,
            monthsSavedWithExtra: monthsSaved,
            interestSavedWithExtra: interestSaved,
            payoffMonthsWithExtra: payoffMonths,
            amortizationSchedule: schedule
        )
    }

    private static func calculateSmartScore(
        trueMonthlyCost: Double,
        monthlyPayment: Double,
        income: Double,
        totalInterest: Double,
        principal: Double,
        termMonths: Int
    ) -> (SmartScoreRating, Double) {
        guard income > 0 else {
            return (.reasonable, 50.0)
        }

        let costToIncomeRatio = trueMonthlyCost / income
        let interestToPrincipalRatio = totalInterest / max(principal, 1)
        let termPenalty = Double(max(termMonths - 60, 0)) / 36.0

        // Weighted score: 0 = best, 100 = worst
        var score: Double = 0

        // Cost-to-income (biggest factor: 50% weight)
        if costToIncomeRatio <= 0.10 {
            score += 0
        } else if costToIncomeRatio <= 0.15 {
            score += (costToIncomeRatio - 0.10) / 0.05 * 20
        } else if costToIncomeRatio <= 0.20 {
            score += 20 + (costToIncomeRatio - 0.15) / 0.05 * 15
        } else if costToIncomeRatio <= 0.30 {
            score += 35 + (costToIncomeRatio - 0.20) / 0.10 * 10
        } else {
            score += 45 + min((costToIncomeRatio - 0.30) / 0.20 * 5, 5)
        }

        // Interest burden (30% weight)
        if interestToPrincipalRatio <= 0.05 {
            score += 0
        } else if interestToPrincipalRatio <= 0.15 {
            score += (interestToPrincipalRatio - 0.05) / 0.10 * 15
        } else if interestToPrincipalRatio <= 0.30 {
            score += 15 + (interestToPrincipalRatio - 0.15) / 0.15 * 10
        } else {
            score += 25 + min((interestToPrincipalRatio - 0.30) / 0.20 * 5, 5)
        }

        // Term length penalty (20% weight)
        score += termPenalty * 20

        // Invert: 100 = best, 0 = worst
        let invertedScore = max(0, min(100, 100 - score))

        let rating: SmartScoreRating
        switch invertedScore {
        case 80...100: rating = .excellent
        case 60..<80: rating = .reasonable
        case 40..<60: rating = .stretch
        case 20..<40: rating = .risky
        default: rating = .overextended
        }

        return (rating, invertedScore)
    }

    private static func calculateExtraPayment(
        principal: Double,
        monthlyRate: Double,
        basePayment: Double,
        extraPayment: Double,
        originalTerm: Int
    ) -> (monthsSaved: Int, interestSaved: Double, payoffMonths: Int) {
        guard extraPayment > 0, monthlyRate > 0 else {
            return (0, 0, originalTerm)
        }

        let totalPayment = basePayment + extraPayment
        var balance = principal
        var months = 0
        var totalInterestWithExtra = 0.0

        while balance > 0 && months < originalTerm * 2 {
            let interestCharge = balance * monthlyRate
            totalInterestWithExtra += interestCharge
            let principalPaid = min(totalPayment - interestCharge, balance)
            balance -= principalPaid
            months += 1
            if balance <= 0.01 { break }
        }

        // Original total interest
        var origBalance = principal
        var origInterest = 0.0
        for _ in 0..<originalTerm {
            let intCharge = origBalance * monthlyRate
            origInterest += intCharge
            origBalance -= (basePayment - intCharge)
        }

        let monthsSaved = originalTerm - months
        let interestSaved = origInterest - totalInterestWithExtra

        return (max(monthsSaved, 0), max(interestSaved, 0), months)
    }

    private static func buildAmortization(
        principal: Double,
        monthlyRate: Double,
        payment: Double,
        termMonths: Int
    ) -> [AmortizationEntry] {
        var entries: [AmortizationEntry] = []
        var balance = principal

        for month in 1...termMonths {
            let interestCharge = balance * monthlyRate
            let principalPaid = min(payment - interestCharge, balance)
            balance -= principalPaid

            entries.append(AmortizationEntry(
                id: month,
                month: month,
                payment: payment,
                principal: principalPaid,
                interest: interestCharge,
                remainingBalance: max(balance, 0)
            ))

            if balance <= 0.01 { break }
        }

        return entries
    }

    static func compare(_ a: Vehicle, _ b: Vehicle) -> ComparisonDelta {
        let resultA = calculate(for: a)
        let resultB = calculate(for: b)

        return ComparisonDelta(
            vehicleA: a.name,
            vehicleB: b.name,
            monthlyCostDiff: resultA.trueMonthlyCost - resultB.trueMonthlyCost,
            totalCostDiff: resultA.totalPaid - resultB.totalPaid,
            fiveYearDiff: resultA.fiveYearCost - resultB.fiveYearCost,
            interestDiff: resultA.totalInterest - resultB.totalInterest
        )
    }
}
