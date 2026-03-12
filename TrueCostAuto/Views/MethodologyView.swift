import SwiftUI

/// Transparency screen explaining all formulas, assumptions, and the DealFit Index scoring model.
struct MethodologyView: View {

    var body: some View {
        ZStack {
            TCTheme.bg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Intro
                    introSection

                    methodSection(
                        title: "True Monthly Cost",
                        icon: "dollarsign.circle.fill",
                        color: TCTheme.accent,
                        content: trueMonthlyCostContent
                    )

                    methodSection(
                        title: "Loan Amortization",
                        icon: "calendar.badge.clock",
                        color: TCTheme.accent2,
                        content: amortizationContent
                    )

                    methodSection(
                        title: "Depreciation Model",
                        icon: "arrow.down.right.circle.fill",
                        color: TCTheme.depreciation,
                        content: depreciationContent
                    )

                    methodSection(
                        title: "DealFit Index™",
                        icon: "gauge.with.dots.needle.67percent",
                        color: TCTheme.good,
                        content: dealFitContent
                    )

                    methodSection(
                        title: "Verdict Classification",
                        icon: "checkmark.shield.fill",
                        color: TCTheme.accent,
                        content: verdictContent
                    )

                    methodSection(
                        title: "Affordability Mode",
                        icon: "arrow.uturn.backward.circle.fill",
                        color: TCTheme.accent2,
                        content: affordabilityContent
                    )

                    methodSection(
                        title: "Assumptions & Limitations",
                        icon: "exclamationmark.triangle.fill",
                        color: TCTheme.warn,
                        content: assumptionsContent
                    )

                    // Footer
                    Text("TrueCost Auto does not provide financial advice. All calculations are estimates based on the inputs you provide. Consult a financial advisor before making major purchase decisions.")
                        .font(.system(size: 11))
                        .foregroundStyle(TCTheme.muted.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Methodology")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Intro

    private var introSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                AppLogo(size: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text("How TrueCost Auto Works")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(TCTheme.text)
                    Text("Full transparency on every number")
                        .font(.system(size: 13))
                        .foregroundStyle(TCTheme.muted)
                }
            }
            Text("Every number TrueCost Auto shows you comes from a documented formula. This page explains exactly how the True Monthly Cost, DealFit Index, Verdict, and Affordability Mode are calculated — so you can trust and verify the results.")
                .font(.system(size: 13))
                .foregroundStyle(TCTheme.muted)
                .lineSpacing(3)
        }
    }

    // MARK: - Section Builder

    private func methodSection<C: View>(
        title: String,
        icon: String,
        color: Color,
        @ViewBuilder content: () -> C
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(TCTheme.text)
            }
            content()
        }
        .padding(16)
        .background(TCTheme.panel.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(TCTheme.line, lineWidth: 1))
    }

    // MARK: - Content Blocks

    @ViewBuilder
    private var trueMonthlyCostContent: some View {
        methodParagraph("True Monthly Cost is the all-in cost of owning the vehicle each month, accounting for financing, operating expenses, and asset loss:")
        formulaBox("True Monthly Cost =\nLoan Payment + Running Costs + Monthly Depreciation")
        methodBullets([
            "Running Costs = Insurance + Fuel + Maintenance + Tires & Other + Warranty",
            "Monthly Depreciation = 5-Year Depreciation ÷ 60 months",
            "Daily Cost = True Monthly Cost × 12 ÷ 365",
        ])
    }

    @ViewBuilder
    private var amortizationContent: some View {
        methodParagraph("Monthly loan payments are computed using the standard amortization formula:")
        formulaBox("Payment = P × [r(1+r)ⁿ] / [(1+r)ⁿ − 1]\n\nWhere:\nP = Amount Financed\nr = Monthly Rate (APR ÷ 12)\nn = Term in Months")
        methodParagraph("Amount Financed = (Vehicle Price + Fees − Down Payment − Trade-In) × (1 + Tax Rate)")
        methodBullets([
            "Bi-weekly payment = Monthly Payment × 12 ÷ 26",
            "Total Interest = (Monthly Payment × n) − Amount Financed",
            "For 0% APR: Payment = Amount Financed ÷ n",
        ])
    }

    @ViewBuilder
    private var depreciationContent: some View {
        methodParagraph("Depreciation is modelled as compound annual decline — the same approach used by most automotive financial tools:")
        formulaBox("Value at Year Y = Price × (1 − Rate)^Y\n\n5-Year Depreciation = Price − Value at Year 5\nMonthly Depreciation = 5-Year Depreciation ÷ 60")
        methodBullets([
            "Default depreciation rate is 15%/yr (adjustable 5–30%).",
            "Typical new vehicles depreciate 15–25%/yr in year 1 and slow over time.",
            "TrueCost uses a flat compound rate for simplicity and consistency.",
        ])
    }

    @ViewBuilder
    private var dealFitContent: some View {
        methodParagraph("The DealFit Index™ is TrueCost Auto's proprietary affordability score from 0 to 100 (higher is better). It weights three factors:")
        formulaBox("DealFit Index = 100 − Weighted Penalty Score\n\n• Cost-to-Income (50% weight)\n• Interest Burden (30% weight)\n• Loan Term Penalty (20% weight)")
        methodParagraph("Cost-to-Income: true monthly cost ÷ monthly income. Ideal < 15%. Penalized progressively up to 40%+.")
        methodParagraph("Interest Burden: total interest ÷ principal. Ideal < 5%. Penalized progressively up to 30%+.")
        methodParagraph("Term Penalty: months beyond 60 ÷ 36, scaled up to 20 points deducted.")
        methodBullets([
            "Score 80–100: Excellent — well within budget",
            "Score 60–79: Reasonable — manageable for most",
            "Score 40–59: Stretch — tight but possible",
            "Score 20–39: Risky — financial strain likely",
            "Score 0–19: Overextended — likely unaffordable",
        ])
        methodParagraph("Without income: DealFit Index defaults to 50 (Reasonable) with only interest burden and term factored in.")
    }

    @ViewBuilder
    private var verdictContent: some View {
        methodParagraph("The Verdict is derived directly from the DealFit Index:")
        methodBullets([
            "DealFit 70–100 → ✓ Good Deal",
            "DealFit 40–69 → ⚠ Caution",
            "DealFit 0–39 → ✗ Not Recommended",
        ])
        methodParagraph("The Verdict is a guide, not a guarantee. A \"Good Deal\" at your income level might still be risky if your circumstances change.")
    }

    @ViewBuilder
    private var affordabilityContent: some View {
        methodParagraph("Affordability Mode reverses the amortization formula to find the maximum financed amount from a target monthly payment:")
        formulaBox("Max Financed =\nMax Loan Payment × [(1+r)ⁿ − 1] / [r × (1+r)ⁿ]\n\nMax Loan Payment =\nMonthly Budget − Estimated Running Costs\n\nMax Vehicle Price ≈\n(Max Financed ÷ (1 + Tax Rate)) + Down Payment + Trade-In")
        methodBullets([
            "Fees are assumed zero in this estimate — actual vehicle prices will be lower once fees are added.",
            "Depreciation is not included in this budget split. Setting aside 15–20% more is advisable.",
        ])
    }

    @ViewBuilder
    private var assumptionsContent: some View {
        methodBullets([
            "All values use the inputs you provide — no external data sources.",
            "Depreciation is a flat compound rate; real depreciation varies by make, model, mileage, and condition.",
            "Running costs are monthly flat estimates; actual costs may fluctuate.",
            "Sales tax is applied to (price + fees − down − trade-in). Some jurisdictions differ.",
            "Insurance and fuel estimates are user-provided; use regional averages as a starting point.",
            "TrueCost Auto does not connect to live market data, lenders, or insurance providers.",
        ])
    }

    // MARK: - Helpers

    private func methodParagraph(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundStyle(TCTheme.muted)
            .lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func formulaBox(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, design: .monospaced))
            .foregroundStyle(TCTheme.accent)
            .lineSpacing(4)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(TCTheme.accent.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(TCTheme.accent.opacity(0.2), lineWidth: 1))
    }

    private func methodBullets(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .font(.system(size: 13))
                        .foregroundStyle(TCTheme.accent)
                    Text(item)
                        .font(.system(size: 13))
                        .foregroundStyle(TCTheme.muted)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MethodologyView()
    }
    .preferredColorScheme(.dark)
}
