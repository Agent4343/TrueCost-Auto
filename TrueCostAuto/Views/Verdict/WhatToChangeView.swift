import SwiftUI

/// Actionable recommendations for improving the deal, with calculated impact.
struct WhatToChangeView: View {

    let result: CalculationResult
    let vehicle: Vehicle
    let currencySymbol: String

    private var recommendations: [Recommendation] {
        var recs: [Recommendation] = []

        // 1. Shorten the term if >= 72 months
        if vehicle.loanTermMonths >= 72 {
            let shorterTerm = max(vehicle.loanTermMonths - 24, 36)
            var v2 = vehicle
            v2.loanTermMonths = shorterTerm
            let r2 = CostCalculator.calculate(for: v2)
            let interestSaved = result.totalInterest - r2.totalInterest
            let paymentDiff = r2.monthlyPayment - result.monthlyPayment
            if interestSaved > 0 {
                recs.append(Recommendation(
                    icon: "calendar.badge.minus",
                    color: TCTheme.good,
                    title: "Shorten your term to \(shorterTerm) months",
                    body: "Saves \(TCTheme.formatCurrency(interestSaved, symbol: currencySymbol)) in interest. Monthly payment goes up by \(TCTheme.formatCurrency(paymentDiff, symbol: currencySymbol))/mo.",
                    impact: .positive
                ))
            }
        }

        // 2. Increase down payment by 10% if vehicle price > 0
        if vehicle.vehiclePrice > 0 && vehicle.downPayment < vehicle.vehiclePrice * 0.3 {
            let extraDown = vehicle.vehiclePrice * 0.10
            var v2 = vehicle
            v2.downPayment += extraDown
            let r2 = CostCalculator.calculate(for: v2)
            let monthlySaving = result.trueMonthlyCost - r2.trueMonthlyCost
            let interestSaved = result.totalInterest - r2.totalInterest
            if monthlySaving > 0 {
                recs.append(Recommendation(
                    icon: "arrow.up.circle.fill",
                    color: TCTheme.accent,
                    title: "Add \(TCTheme.formatCurrency(extraDown, symbol: currencySymbol)) more to down payment",
                    body: "Reduces your monthly cost by \(TCTheme.formatCurrency(monthlySaving, symbol: currencySymbol))/mo and saves \(TCTheme.formatCurrency(interestSaved, symbol: currencySymbol)) in interest.",
                    impact: .positive
                ))
            }
        }

        // 3. APR alert — if > 8%
        if vehicle.interestRate > 8.0 {
            var v2 = vehicle
            v2.interestRate = 6.99
            let r2 = CostCalculator.calculate(for: v2)
            let interestSaved = result.totalInterest - r2.totalInterest
            recs.append(Recommendation(
                icon: "percent",
                color: TCTheme.warn,
                title: "Shop for a lower APR",
                body: "Dropping to 6.99% APR would save \(TCTheme.formatCurrency(interestSaved, symbol: currencySymbol)) in interest over the life of the loan.",
                impact: .positive
            ))
        }

        // 4. Budget warning — true cost > monthly budget
        if vehicle.monthlyBudget > 0 && result.trueMonthlyCost > vehicle.monthlyBudget {
            let overBudget = result.trueMonthlyCost - vehicle.monthlyBudget
            recs.append(Recommendation(
                icon: "exclamationmark.triangle.fill",
                color: TCTheme.bad,
                title: "Over your \(TCTheme.formatCurrency(vehicle.monthlyBudget, symbol: currencySymbol)) budget",
                body: "True cost exceeds your budget by \(TCTheme.formatCurrency(overBudget, symbol: currencySymbol))/mo. Consider a lower price, higher down payment, or shorter term.",
                impact: .negative
            ))
        }

        // 5. Long depreciation drain
        if result.monthlyDepreciation > result.monthlyPayment * 0.35 {
            recs.append(Recommendation(
                icon: "arrow.down.right.circle.fill",
                color: TCTheme.depreciation,
                title: "High depreciation is a major cost driver",
                body: "Depreciation accounts for \(Int(result.monthlyDepreciation / result.trueMonthlyCost * 100))% of your true monthly cost. Certified pre-owned vehicles typically depreciate slower in their first years.",
                impact: .neutral
            ))
        }

        if recs.isEmpty {
            recs.append(Recommendation(
                icon: "checkmark.seal.fill",
                color: TCTheme.good,
                title: "This deal looks solid",
                body: "No major red flags detected. Your financing terms and cost structure are within healthy ranges.",
                impact: .positive
            ))
        }

        return recs
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(TCTheme.warn)
                Text("What to Change")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(TCTheme.text)
            }

            ForEach(recommendations) { rec in
                RecommendationRow(rec: rec)
            }
        }
    }
}

// MARK: - Recommendation Model

struct Recommendation: Identifiable {
    var id: String { title }
    let icon: String
    let color: Color
    let title: String
    let body: String
    let impact: ImpactType

    enum ImpactType { case positive, negative, neutral }
}

// MARK: - Row

struct RecommendationRow: View {
    let rec: Recommendation

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: rec.icon)
                .font(.system(size: 16))
                .foregroundStyle(rec.color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(rec.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(TCTheme.text)
                Text(rec.body)
                    .font(.system(size: 12))
                    .foregroundStyle(TCTheme.muted)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(rec.color.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(rec.color.opacity(0.18), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(rec.title). \(rec.body)")
    }
}
