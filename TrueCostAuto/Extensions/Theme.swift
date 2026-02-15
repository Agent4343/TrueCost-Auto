import SwiftUI

enum TCTheme {
    // Core palette
    static let bg = Color(red: 0.043, green: 0.071, blue: 0.125)
    static let panel = Color(red: 0.059, green: 0.102, blue: 0.180)
    static let panelAlt = Color(red: 0.047, green: 0.086, blue: 0.157)
    static let text = Color(red: 0.914, green: 0.933, blue: 0.988)
    static let muted = Color(red: 0.624, green: 0.690, blue: 0.816)
    static let line = Color(red: 0.118, green: 0.169, blue: 0.271)
    static let good = Color(red: 0.157, green: 0.820, blue: 0.486)
    static let warn = Color(red: 1.0, green: 0.8, blue: 0.0)
    static let bad = Color(red: 1.0, green: 0.302, blue: 0.302)
    static let accent = Color(red: 0.416, green: 0.655, blue: 1.0)
    static let accent2 = Color(red: 0.643, green: 0.420, blue: 1.0)
    static let depreciation = Color(red: 1.0, green: 0.6, blue: 0.3)

    static let accentGradient = LinearGradient(
        colors: [accent, accent2],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroGradient = LinearGradient(
        colors: [
            accent.opacity(0.14),
            accent2.opacity(0.12)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardBackground = panel.opacity(0.65)

    static func scoreColor(for rating: SmartScoreRating) -> Color {
        switch rating {
        case .excellent: return good
        case .reasonable: return good
        case .stretch: return warn
        case .risky: return bad.opacity(0.8)
        case .overextended: return bad
        }
    }

    // Currency-aware formatting
    static func formatCurrency(_ value: Double, symbol: String = "$") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = symbol
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(symbol)0"
    }

    static func formatCurrencyWithCents(_ value: Double, symbol: String = "$") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = symbol
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(symbol)0.00"
    }

    static func formatPercent(_ value: Double) -> String {
        String(format: "%.1f%%", value)
    }
}

struct TCCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(TCTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(TCTheme.line, lineWidth: 1)
            )
    }
}

struct TCFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(TCTheme.panelAlt.opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(TCTheme.line, lineWidth: 1)
            )
    }
}

struct TCTileStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(TCTheme.panelAlt.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(TCTheme.line, lineWidth: 1)
            )
    }
}

extension View {
    func tcCard() -> some View { modifier(TCCardStyle()) }
    func tcField() -> some View { modifier(TCFieldStyle()) }
    func tcTile() -> some View { modifier(TCTileStyle()) }
}
