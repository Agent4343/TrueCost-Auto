import SwiftUI

struct BreakdownTile: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(color)
                Text(title)
                    .font(.system(size: 12))
                    .foregroundStyle(TCTheme.muted)
            }

            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(TCTheme.text)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(subtitle)
                .font(.system(size: 11))
                .foregroundStyle(TCTheme.muted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .tcTile()
    }
}

#Preview {
    HStack {
        BreakdownTile(
            title: "Loan Payment",
            value: "$345",
            subtitle: "$159 bi-weekly",
            icon: "creditcard.fill",
            color: TCTheme.accent
        )
        BreakdownTile(
            title: "Total Interest",
            value: "$9,480",
            subtitle: "over 84 months",
            icon: "percent",
            color: TCTheme.warn
        )
    }
    .padding()
    .background(TCTheme.bg)
    .preferredColorScheme(.dark)
}
