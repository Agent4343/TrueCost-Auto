import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    @State private var animateIcon = false

    private let pages: [(icon: String, title: String, body: String, color: Color)] = [
        (
            "dollarsign.circle.fill",
            "See the Real Cost",
            "Your car payment is just the start. TrueCost Auto shows you the full monthly picture — payment, insurance, fuel, maintenance, and depreciation.",
            TCTheme.accent
        ),
        (
            "gauge.with.dots.needle.67percent",
            "Smart Score",
            "Instantly see if a vehicle fits your budget. Our Smart Score analyzes your income ratio, interest burden, and loan term to give you a clear answer.",
            TCTheme.good
        ),
        (
            "chart.bar.xaxis",
            "Track & Compare",
            "See your vehicle's value year-by-year. Save multiple vehicles and compare them side-by-side to find which one truly costs less over time.",
            TCTheme.accent2
        ),
    ]

    var body: some View {
        ZStack {
            TCTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo
                AppLogo(size: 80)
                    .shadow(color: TCTheme.accent.opacity(0.3), radius: 20, y: 10)
                    .scaleEffect(animateIcon ? 1.0 : 0.8)
                    .opacity(animateIcon ? 1 : 0)
                    .padding(.bottom, 32)

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        pageView(pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 280)

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
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
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

                if currentPage < pages.count - 1 {
                    Button {
                        dismiss()
                    } label: {
                        Text("Skip")
                            .font(.system(size: 14))
                            .foregroundStyle(TCTheme.muted)
                    }
                    .padding(.top, 12)
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

            Text(page.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(TCTheme.text)

            Text(page.body)
                .font(.system(size: 15))
                .foregroundStyle(TCTheme.muted)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 32)
        }
    }
}

#Preview {
    OnboardingView()
}
