import SwiftUI

struct AppLogo: View {
    let size: CGFloat

    private var gearRadius: CGFloat { size * 0.42 }
    private var toothCount: Int { 8 }
    private var arrowSize: CGFloat { size * 0.22 }

    var body: some View {
        ZStack {
            // Gradient background
            RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                .fill(TCTheme.accentGradient)

            // Top-left shine for depth
            RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.20), location: 0),
                            .init(color: .white.opacity(0.05), location: 0.35),
                            .init(color: .clear, location: 0.55)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Gear + Sync icon
            gearSyncIcon
                .frame(width: size * 0.7, height: size * 0.7)
        }
        .frame(width: size, height: size)
    }

    private var gearSyncIcon: some View {
        ZStack {
            // Outer gear ring with teeth
            GearShape(toothCount: toothCount, toothDepth: 0.15)
                .fill(.white.opacity(0.93))

            // Inner circle cutout (makes it a ring)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            TCTheme.accent.opacity(0.8),
                            TCTheme.accent2.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.38, height: size * 0.38)

            // Sync arrows (two curved arrows forming a cycle)
            syncArrows
        }
    }

    private var syncArrows: some View {
        let arrowScale = size * 0.16

        return ZStack {
            // Top-right arrow (clockwise curve)
            SyncArrowShape(clockwise: true)
                .stroke(.white.opacity(0.95), style: StrokeStyle(
                    lineWidth: max(1.5, size * 0.04),
                    lineCap: .round
                ))
                .frame(width: arrowScale, height: arrowScale)
                .offset(x: arrowScale * 0.15, y: -arrowScale * 0.3)

            // Arrowhead top
            ArrowheadShape()
                .fill(.white.opacity(0.95))
                .frame(width: max(3, size * 0.07), height: max(3, size * 0.07))
                .rotationEffect(.degrees(-30))
                .offset(x: arrowScale * 0.55, y: -arrowScale * 0.28)

            // Bottom-left arrow (counter-clockwise curve)
            SyncArrowShape(clockwise: false)
                .stroke(.white.opacity(0.95), style: StrokeStyle(
                    lineWidth: max(1.5, size * 0.04),
                    lineCap: .round
                ))
                .frame(width: arrowScale, height: arrowScale)
                .offset(x: -arrowScale * 0.15, y: arrowScale * 0.3)

            // Arrowhead bottom
            ArrowheadShape()
                .fill(.white.opacity(0.95))
                .frame(width: max(3, size * 0.07), height: max(3, size * 0.07))
                .rotationEffect(.degrees(150))
                .offset(x: -arrowScale * 0.55, y: arrowScale * 0.28)
        }
    }
}

// MARK: - Gear Shape

struct GearShape: Shape {
    let toothCount: Int
    let toothDepth: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * (1 - toothDepth)
        let anglePerTooth = (2 * .pi) / Double(toothCount)
        let toothWidth = anglePerTooth * 0.35

        for i in 0..<toothCount {
            let startAngle = Double(i) * anglePerTooth - .pi / 2

            // Inner arc (valley)
            let valleyStart = startAngle + toothWidth
            let valleyEnd = startAngle + anglePerTooth - toothWidth

            if i == 0 {
                let x = center.x + CGFloat(cos(startAngle)) * outerRadius
                let y = center.y + CGFloat(sin(startAngle)) * outerRadius
                path.move(to: CGPoint(x: x, y: y))
            }

            // Outer tooth arc
            let toothEnd = startAngle + toothWidth
            path.addArc(center: center, radius: outerRadius,
                        startAngle: .radians(startAngle),
                        endAngle: .radians(toothEnd),
                        clockwise: false)

            // Transition to inner
            let ix1 = center.x + CGFloat(cos(valleyStart)) * innerRadius
            let iy1 = center.y + CGFloat(sin(valleyStart)) * innerRadius
            path.addLine(to: CGPoint(x: ix1, y: iy1))

            // Inner arc (valley)
            path.addArc(center: center, radius: innerRadius,
                        startAngle: .radians(valleyStart),
                        endAngle: .radians(valleyEnd),
                        clockwise: false)

            // Transition back to outer
            let ox = center.x + CGFloat(cos(valleyEnd)) * outerRadius
            let oy = center.y + CGFloat(sin(valleyEnd)) * outerRadius
            path.addLine(to: CGPoint(x: ox, y: oy))

            // Outer tooth arc to next
            let nextStart = startAngle + anglePerTooth
            path.addArc(center: center, radius: outerRadius,
                        startAngle: .radians(valleyEnd),
                        endAngle: .radians(nextStart),
                        clockwise: false)
        }

        path.closeSubpath()
        return path
    }
}

// MARK: - Sync Arrow Shape

struct SyncArrowShape: Shape {
    let clockwise: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        if clockwise {
            path.addArc(center: center, radius: radius,
                        startAngle: .degrees(-180),
                        endAngle: .degrees(30),
                        clockwise: false)
        } else {
            path.addArc(center: center, radius: radius,
                        startAngle: .degrees(0),
                        endAngle: .degrees(210),
                        clockwise: false)
        }

        return path
    }
}

// MARK: - Arrowhead Shape

struct ArrowheadShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
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
