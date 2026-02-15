import SwiftUI

struct AppLogo: View {
    let size: CGFloat

    private var cornerRadius: CGFloat { size * 0.26 }
    private var carSize: CGFloat { size * 0.36 }
    private var badgeSize: CGFloat { size * 0.34 }

    var body: some View {
        ZStack {
            // Gradient background
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(TCTheme.accentGradient)

            // Top-left shine for depth
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.22), location: 0),
                            .init(color: .white.opacity(0.06), location: 0.35),
                            .init(color: .clear, location: 0.55)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Motion lines behind the car
            HStack(spacing: size * 0.03) {
                ForEach(0..<3, id: \.self) { i in
                    Capsule()
                        .fill(.white.opacity(0.35 - Double(i) * 0.1))
                        .frame(
                            width: size * (0.08 - Double(i) * 0.015),
                            height: size * 0.025
                        )
                }
            }
            .offset(x: -size * 0.28, y: -size * 0.04)

            // Car silhouette
            Image(systemName: "car.fill")
                .font(.system(size: carSize))
                .foregroundStyle(.white.opacity(0.95))
                .offset(x: -size * 0.02, y: -size * 0.04)

            // Dollar cost badge (bottom-right)
            ZStack {
                Circle()
                    .fill(.white)
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [TCTheme.accent, TCTheme.accent2],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: max(1, size * 0.02)
                    )
                Text("$")
                    .font(.system(
                        size: badgeSize * 0.52,
                        weight: .black,
                        design: .rounded
                    ))
                    .foregroundStyle(TCTheme.accent2)
            }
            .frame(width: badgeSize, height: badgeSize)
            .shadow(color: .black.opacity(0.22), radius: size * 0.04, y: size * 0.02)
            .offset(x: size * 0.24, y: size * 0.22)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ZStack {
        TCTheme.bg.ignoresSafeArea()

        VStack(spacing: 30) {
            AppLogo(size: 80)
            AppLogo(size: 42)
            AppLogo(size: 28)
        }
    }
}
