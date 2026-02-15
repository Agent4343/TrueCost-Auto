import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0

    private let pages: [(icon: String, title: String, body: String)] = [
        (
            "dollarsign.circle.fill",
            "See the Real Cost",
            "Your car payment is just the start. TrueCost Auto shows you the full monthly picture — payment, insurance, fuel, maintenance, and more."
        ),
        (
            "gauge.with.dots.needle.67percent",
            "Smart Score",
            "Instantly see if a vehicle fits your budget. Our Smart Score analyzes your income ratio, interest burden, and loan term to give you a clear answer."
        ),
        (
            "arrow.left.arrow.right",
            "Compare & Decide",
            "Save multiple vehicles and compare them side-by-side. See which one truly costs less over 5 years — not just which has the lowest sticker price."
        ),
    ]

    var body: some View {
        ZStack {
            TCTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(TCTheme.accentGradient)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text("TC")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                    )
                    .shadow(color: TCTheme.accent.opacity(0.3), radius: 20, y: 10)
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
    }

    private func pageView(_ page: (icon: String, title: String, body: String)) -> some View {
        VStack(spacing: 16) {
            Image(systemName: page.icon)
                .font(.system(size: 40))
                .foregroundStyle(TCTheme.accent)
                .padding(.bottom, 4)

            Text(page.title)
                .font(.system(size: 22, weight: .bold))
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
