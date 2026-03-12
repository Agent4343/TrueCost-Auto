import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    @State private var animateIcon = false

    private let pages: [(icon: String, title: String, body: String, color: Color)] = [
        (
            "checkmark.shield.fill",
            "Deal Verdict, Not Just Numbers",
            "TrueCost Auto goes beyond a monthly payment. It gives you a verdict — Good, Caution, or Not Recommended — based on your income, interest load, and true ownership cost.",
            TCTheme.good
        ),
        (
            "arrow.uturn.backward.circle.fill",
            "What Can I Actually Afford?",
            "Affordability Mode flips the calculation: enter your monthly budget and we compute the maximum vehicle price you can realistically afford — factoring in insurance, fuel, and maintenance.",
            TCTheme.accent2
        ),
        (
            "gauge.with.dots.needle.67percent",
            "DealFit Index™",
            "Our proprietary score (0–100) weights cost-to-income ratio, interest burden, and loan term length. Tap 'Methodology' any time to see exactly how it's calculated.",
            TCTheme.accent
        ),
    ]

    var body: some View {
        ZStack {
            TCTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo
                AppLogo(size: 72)
                    .shadow(color: TCTheme.accent.opacity(0.3), radius: 20, y: 10)
                    .scaleEffect(animateIcon ? 1.0 : 0.8)
                    .opacity(animateIcon ? 1 : 0)
                    .padding(.bottom, 8)

                Text("TrueCost Auto")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(TCTheme.text)
                    .opacity(animateIcon ? 1 : 0)
                    .padding(.bottom, 28)

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        pageView(pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 300)

                Spacer()

                // Button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation(.spring(response: 0.3)) {
                            currentPage += 1
                        }
                    } else {
                        dismiss()
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Next" : "Start Checking Deals")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(TCTheme.accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: TCTheme.accent.opacity(0.25), radius: 15, y: 8)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .accessibilityLabel(currentPage < pages.count - 1 ? "Next" : "Start checking deals")

                if currentPage < pages.count - 1 {
                    Button {
                        dismiss()
                    } label: {
                        Text("Skip")
                            .font(.system(size: 14))
                            .foregroundStyle(TCTheme.muted)
                    }
                    .padding(.top, 12)
                    .accessibilityLabel("Skip onboarding")
                }

                Spacer()
                    .frame(height: 40)
            }
        }
        .interactiveDismissDisabled(false)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateIcon = true
            }
        }
    }

    private func pageView(_ page: (icon: String, title: String, body: String, color: Color)) -> some View {
        VStack(spacing: 16) {
            Image(systemName: page.icon)
                .font(.system(size: 44))
                .foregroundStyle(page.color)
                .padding(.bottom, 4)
                .shadow(color: page.color.opacity(0.3), radius: 8, y: 4)
                .accessibilityHidden(true)

            Text(page.title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(TCTheme.text)
                .multilineTextAlignment(.center)

            Text(page.body)
                .font(.system(size: 14))
                .foregroundStyle(TCTheme.muted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 28)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(page.title). \(page.body)")
    }
}

#Preview {
    OnboardingView()
}
