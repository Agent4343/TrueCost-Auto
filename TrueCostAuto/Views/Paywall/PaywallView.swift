import SwiftUI

/// One-time purchase paywall for DealFit Pro features.
struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreKitManager.self) private var storeKit

    private let features: [(icon: String, title: String, body: String)] = [
        ("arrow.up.arrow.down.circle.fill", "Side-by-Side Comparison", "Compare up to 3 vehicles simultaneously with cost delta breakdowns."),
        ("square.and.arrow.up.fill", "Advanced Export", "Export your verdict as a formatted summary to share or save offline."),
        ("chart.bar.xaxis.ascending", "Full Year-by-Year Projections", "Unlock 7-year equity and cost projection charts for any vehicle."),
        ("lock.open.fill", "All Future Features", "Every new DealFit Pro feature, forever — no recurring charges."),
    ]

    var body: some View {
        ZStack {
            TCTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                // Close
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(TCTheme.muted)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close")
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                ScrollView {
                    VStack(spacing: 24) {
                        // Hero
                        VStack(spacing: 10) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(TCTheme.warn)
                                .shadow(color: TCTheme.warn.opacity(0.4), radius: 12, y: 6)

                            Text("DealFit Pro")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundStyle(TCTheme.text)

                            Text("One-time purchase. No subscription.")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(TCTheme.good)

                            if let product = storeKit.product {
                                Text(product.displayPrice)
                                    .font(.system(size: 36, weight: .black, design: .rounded))
                                    .foregroundStyle(TCTheme.accent)
                            } else {
                                Text("unlock once, use forever")
                                    .font(.system(size: 15))
                                    .foregroundStyle(TCTheme.muted)
                            }
                        }

                        // Features
                        VStack(spacing: 12) {
                            ForEach(features, id: \.title) { feature in
                                HStack(alignment: .top, spacing: 14) {
                                    Image(systemName: feature.icon)
                                        .font(.system(size: 18))
                                        .foregroundStyle(TCTheme.accent)
                                        .frame(width: 26)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(feature.title)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(TCTheme.text)
                                        Text(feature.body)
                                            .font(.system(size: 12))
                                            .foregroundStyle(TCTheme.muted)
                                            .lineSpacing(2)
                                    }
                                    Spacer()
                                }
                                .padding(14)
                                .background(TCTheme.panel.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(TCTheme.line, lineWidth: 1))
                            }
                        }

                        // Error message
                        if let error = storeKit.errorMessage {
                            Text(error)
                                .font(.system(size: 13))
                                .foregroundStyle(TCTheme.bad)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                        }

                        // Purchase button
                        Button {
                            Task { await storeKit.purchase() }
                        } label: {
                            ZStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "lock.open.fill")
                                        .font(.system(size: 16))
                                    Text(storeKit.product != nil
                                         ? "Unlock for \(storeKit.product!.displayPrice)"
                                         : "Unlock DealFit Pro")
                                        .font(.system(size: 17, weight: .bold))
                                }
                                .foregroundStyle(.white)
                                .opacity(storeKit.isPurchasing ? 0 : 1)

                                if storeKit.isPurchasing {
                                    ProgressView()
                                        .tint(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(TCTheme.accentGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: TCTheme.accent.opacity(0.3), radius: 12, y: 6)
                        }
                        .buttonStyle(.plain)
                        .disabled(storeKit.isPurchasing)
                        .accessibilityLabel("Unlock DealFit Pro")

                        // Restore
                        Button {
                            Task { await storeKit.restore() }
                        } label: {
                            Text("Restore Purchase")
                                .font(.system(size: 14))
                                .foregroundStyle(TCTheme.muted)
                        }
                        .buttonStyle(.plain)
                        .disabled(storeKit.isPurchasing)
                        .accessibilityLabel("Restore previous purchase")

                        Text("Payment is charged once to your Apple ID account. No auto-renewal. See Privacy Policy for details.")
                            .font(.system(size: 11))
                            .foregroundStyle(TCTheme.muted.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

#Preview {
    PaywallView()
        .environment(StoreKitManager())
        .preferredColorScheme(.dark)
}
