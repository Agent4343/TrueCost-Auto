import SwiftUI

struct SmartScoreView: View {
    let result: CalculationResult
    @State private var animateBar = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Smart Score")
                .font(.system(size: 11))
                .foregroundStyle(TCTheme.muted)

            HStack {
                Text(result.smartScore.rawValue)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(TCTheme.text)
                Spacer()
                Circle()
                    .fill(TCTheme.scoreColor(for: result.smartScore))
                    .frame(width: 10, height: 10)
                    .shadow(color: TCTheme.scoreColor(for: result.smartScore).opacity(0.4), radius: 4)
            }

            // Score bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(Color.white.opacity(0.06))

                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(scoreGradient)
                        .frame(width: animateBar ? geo.size.width * (result.smartScoreValue / 100.0) : 0)
                }
            }
            .frame(height: 8)
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )

            if let pct = result.incomePercentage {
                Text(String(format: "%.1f%% of income", pct))
                    .font(.system(size: 11))
                    .foregroundStyle(TCTheme.muted)
            }
        }
        .padding(12)
        .frame(minWidth: 148)
        .background(TCTheme.panelAlt.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.4)) {
                animateBar = true
            }
        }
    }

    private var scoreGradient: LinearGradient {
        let color = TCTheme.scoreColor(for: result.smartScore)
        return LinearGradient(
            colors: [color, color.opacity(0.7)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

#Preview {
    let result = CostCalculator.calculate(for: .example)
    SmartScoreView(result: result)
        .padding()
        .background(TCTheme.bg)
        .preferredColorScheme(.dark)
}
