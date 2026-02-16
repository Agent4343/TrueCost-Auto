import SwiftUI

struct TrueCostHeroCard: View {
    let result: CalculationResult

    @State private var animateValue = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                // Left: True Monthly Cost
                VStack(alignment: .leading, spacing: 6) {
                    Text("True Monthly Cost")
                        .font(.system(size: 13))
                        .foregroundStyle(TCTheme.muted)

                    Text(TCTheme.formatCurrency(result.trueMonthlyCost))
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundStyle(TCTheme.text)
                        .contentTransition(.numericText(value: result.trueMonthlyCost))
                        .scaleEffect(animateValue ? 1.0 : 0.8)
                        .opacity(animateValue ? 1 : 0)

                    HStack(spacing: 8) {
                        Text("~\(TCTheme.formatCurrencyWithCents(result.dailyCost))/day")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(TCTheme.accent)
                        Text("incl. depreciation")
                            .font(.system(size: 11))
                            .foregroundStyle(TCTheme.muted)
                    }
                }

                Spacer()

                // Right: Smart Score
                SmartScoreView(result: result)
            }
            .padding(16)
        }
        .background(TCTheme.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [TCTheme.accent.opacity(0.3), TCTheme.accent2.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("True monthly cost \(TCTheme.formatCurrency(result.trueMonthlyCost)), approximately \(TCTheme.formatCurrencyWithCents(result.dailyCost)) per day, Smart Score \(result.smartScore.rawValue)")
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateValue = true
            }
        }
    }
}

#Preview {
    let result = CostCalculator.calculate(for: .example)
    TrueCostHeroCard(result: result)
        .padding()
        .background(TCTheme.bg)
        .preferredColorScheme(.dark)
}
